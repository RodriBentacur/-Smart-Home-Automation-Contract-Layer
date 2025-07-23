(define-non-fungible-token device-ownership uint)

(define-data-var next-device-id uint u1)
(define-data-var contract-owner principal tx-sender)
(define-data-var energy-price-per-unit uint u100)
(define-data-var next-rule-id uint u1)
(define-data-var next-proposal-id uint u1)

(define-map devices uint {
    owner: principal,
    device-type: (string-ascii 50),
    energy-usage: uint,
    status: bool,
    location: (string-ascii 100)
})

(define-map device-permissions uint (list 10 principal))
(define-map energy-bills principal uint)

(define-map automation-rules uint {
    device-id: uint,
    trigger-type: (string-ascii 20),
    trigger-value: (string-ascii 50),
    action: (string-ascii 50),
    active: bool,
    creator: principal
})

(define-map dao-proposals uint {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposal-type: (string-ascii 30),
    votes-for: uint,
    votes-against: uint,
    deadline: uint,
    executed: bool
})

(define-map proposal-votes {proposal-id: uint, voter: principal} bool)

(define-constant ERR-NOT-AUTHORIZED (err u1001))
(define-constant ERR-DEVICE-NOT-FOUND (err u1002))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1003))
(define-constant ERR-PROPOSAL-EXPIRED (err u1004))
(define-constant ERR-ALREADY-VOTED (err u1005))
(define-constant ERR-RULE-NOT-FOUND (err u1007))

(define-public (register-device (device-type (string-ascii 50)) (location (string-ascii 100)))
    (let ((device-id (var-get next-device-id)))
        (try! (nft-mint? device-ownership device-id tx-sender))
        (map-set devices device-id {
            owner: tx-sender,
            device-type: device-type,
            energy-usage: u0,
            status: true,
            location: location
        })
        (var-set next-device-id (+ device-id u1))
        (ok device-id)
    )
)

(define-public (transfer-device (device-id uint) (new-owner principal))
    (let ((device (unwrap! (map-get? devices device-id) ERR-DEVICE-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get owner device)) ERR-NOT-AUTHORIZED)
        (try! (nft-transfer? device-ownership device-id tx-sender new-owner))
        (map-set devices device-id (merge device {owner: new-owner}))
        (ok true)
    )
)

(define-public (grant-device-access (device-id uint) (user principal))
    (let ((device (unwrap! (map-get? devices device-id) ERR-DEVICE-NOT-FOUND))
          (current-permissions (default-to (list) (map-get? device-permissions device-id))))
        (asserts! (is-eq tx-sender (get owner device)) ERR-NOT-AUTHORIZED)
        (map-set device-permissions device-id (unwrap! (as-max-len? (append current-permissions user) u10) ERR-NOT-AUTHORIZED))
        (ok true)
    )
)

(define-public (revoke-device-access (device-id uint))
    (let ((device (unwrap! (map-get? devices device-id) ERR-DEVICE-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get owner device)) ERR-NOT-AUTHORIZED)
        (map-delete device-permissions device-id)
        (ok true)
    )
)

(define-public (update-energy-usage (device-id uint) (usage uint))
    (let ((device (unwrap! (map-get? devices device-id) ERR-DEVICE-NOT-FOUND))
          (current-permissions (default-to (list) (map-get? device-permissions device-id))))
        (asserts! (or 
            (is-eq tx-sender (get owner device))
            (is-some (index-of current-permissions tx-sender))
        ) ERR-NOT-AUTHORIZED)
        (map-set devices device-id (merge device {energy-usage: (+ (get energy-usage device) usage)}))
        (let ((energy-cost (* usage (var-get energy-price-per-unit)))
              (current-bill (default-to u0 (map-get? energy-bills (get owner device)))))
            (map-set energy-bills (get owner device) (+ current-bill energy-cost))
            (ok true)
        )
    )
)

(define-public (pay-energy-bill)
    (let ((bill-amount (default-to u0 (map-get? energy-bills tx-sender))))
        (asserts! (> bill-amount u0) ERR-INSUFFICIENT-BALANCE)
        (try! (stx-transfer? bill-amount tx-sender (var-get contract-owner)))
        (map-delete energy-bills tx-sender)
        (ok bill-amount)
    )
)

(define-public (create-automation-rule (device-id uint) (trigger-type (string-ascii 20)) (trigger-value (string-ascii 50)) (action (string-ascii 50)))
    (let ((device (unwrap! (map-get? devices device-id) ERR-DEVICE-NOT-FOUND))
          (rule-id (var-get next-rule-id))
          (current-permissions (default-to (list) (map-get? device-permissions device-id))))
        (asserts! (or 
            (is-eq tx-sender (get owner device))
            (is-some (index-of current-permissions tx-sender))
        ) ERR-NOT-AUTHORIZED)
        (map-set automation-rules rule-id {
            device-id: device-id,
            trigger-type: trigger-type,
            trigger-value: trigger-value,
            action: action,
            active: true,
            creator: tx-sender
        })
        (var-set next-rule-id (+ rule-id u1))
        (ok rule-id)
    )
)

(define-public (toggle-automation-rule (rule-id uint))
    (let ((rule (unwrap! (map-get? automation-rules rule-id) ERR-RULE-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get creator rule)) ERR-NOT-AUTHORIZED)
        (map-set automation-rules rule-id (merge rule {active: (not (get active rule))}))
        (ok true)
    )
)

(define-public (execute-automation-rule (rule-id uint))
    (let ((rule (unwrap! (map-get? automation-rules rule-id) ERR-RULE-NOT-FOUND))
          (device (unwrap! (map-get? devices (get device-id rule)) ERR-DEVICE-NOT-FOUND)))
        (asserts! (get active rule) ERR-NOT-AUTHORIZED)
        (map-set devices (get device-id rule) (merge device {status: (not (get status device))}))
        (ok true)
    )
)

(define-public (create-dao-proposal (title (string-ascii 100)) (description (string-ascii 500)) (proposal-type (string-ascii 30)) (deadline uint))
    (let ((proposal-id (var-get next-proposal-id)))
        (map-set dao-proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            proposal-type: proposal-type,
            votes-for: u0,
            votes-against: u0,
            deadline: deadline,
            executed: false
        })
        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
    (let ((proposal (unwrap! (map-get? dao-proposals proposal-id) ERR-DEVICE-NOT-FOUND)))
        (asserts! (< burn-block-height (get deadline proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (is-none (map-get? proposal-votes {proposal-id: proposal-id, voter: tx-sender})) ERR-ALREADY-VOTED)
        (map-set proposal-votes {proposal-id: proposal-id, voter: tx-sender} vote-for)
        (if vote-for
            (map-set dao-proposals proposal-id (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
            (map-set dao-proposals proposal-id (merge proposal {votes-against: (+ (get votes-against proposal) u1)}))
        )
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? dao-proposals proposal-id) ERR-DEVICE-NOT-FOUND)))
        (asserts! (> burn-block-height (get deadline proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (not (get executed proposal)) ERR-NOT-AUTHORIZED)
        (asserts! (> (get votes-for proposal) (get votes-against proposal)) ERR-NOT-AUTHORIZED)
        (map-set dao-proposals proposal-id (merge proposal {executed: true}))
        (ok true)
    )
)



(define-read-only (get-device-info (device-id uint))
    (map-get? devices device-id)
)

(define-read-only (get-device-permissions (device-id uint))
    (map-get? device-permissions device-id)
)

(define-read-only (get-energy-bill (user principal))
    (map-get? energy-bills user)
)

(define-read-only (get-automation-rule (rule-id uint))
    (map-get? automation-rules rule-id)
)

(define-read-only (get-dao-proposal (proposal-id uint))
    (map-get? dao-proposals proposal-id)
)

(define-read-only (get-proposal-vote (proposal-id uint) (voter principal))
    (map-get? proposal-votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-device-owner (device-id uint))
    (nft-get-owner? device-ownership device-id)
)

(define-read-only (get-energy-price)
    (var-get energy-price-per-unit)
)
