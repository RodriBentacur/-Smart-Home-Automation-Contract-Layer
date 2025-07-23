> Decentralized IoT device management powered by Stacks blockchain and Clarity smart contracts

## 🌟 Overview

Transform your smart home into a decentralized, secure ecosystem where you truly own and control your IoT devices. This contract layer provides ownership transparency, role-based access control, and democratic governance for smart home automation.

## ✨ Key Features

### 🔐 Device Ownership NFTs
- Each IoT device is represented as a unique NFT
- True ownership with transferable rights
- Transparent ownership history on-chain

### 👥 Role-Based Access Control  
- Grant and revoke device access permissions
- Flexible role management system
- Secure wallet-based authentication

### ⚡ Energy Usage & Billing
- Real-time energy consumption tracking
- Automated billing system with STX payments
- Transparent usage analytics

### 🤖 Tokenized Automation Rules
- Create time-based and trigger-based automations
- Toggle rules on/off dynamically
- Permission-based rule management

### 🗳️ DAO Governance
- Vote on firmware updates and vendor trust
- Proposal-based decision making
- Democratic smart home management

## 🚀 Quick Start

### Prerequisites
- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with STX balance

### Installation

```bash
git clone https://github.com/yourusername/smart-home-automation-contract-layer
cd smart-home-automation-contract-layer
clarinet integrate
```

### Deploy Contract

```bash
clarinet deployments generate --devnet
clarinet deployments apply -p deployments/devnet.devnet-plan.yaml
```

## 📖 Usage Guide

### 🏷️ Register a New Device

```clarity
(contract-call? .smart-home-automation register-device "smart-thermostat" "living-room")
```

### 🔄 Transfer Device Ownership

```clarity
(contract-call? .smart-home-automation transfer-device u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### 👤 Grant Device Access

```clarity
(contract-call? .smart-home-automation grant-device-access u1 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
```

### ⚡ Update Energy Usage

```clarity
(contract-call? .smart-home-automation update-energy-usage u1 u50)
```

### 💳 Pay Energy Bill

```clarity
(contract-call? .smart-home-automation pay-energy-bill)
```

### 🤖 Create Automation Rule

```clarity
(contract-call? .smart-home-automation create-automation-rule u1 "time" "18:00" "turn-on")
```

### 📝 Create DAO Proposal

```clarity
(contract-call? .smart-home-automation create-dao-proposal 
  "Approve Firmware v2.1" 
  "Security updates and performance improvements" 
  "firmware-update" 
  u1000)
```

### 🗳️ Vote on Proposal

```clarity
(contract-call? .smart-home-automation vote-on-proposal u1 true)
```

## 🔍 Query Functions

### Get Device Information
```clarity
(contract-call? .smart-home-automation get-device-info u1)
```

### Check Energy Bill
```clarity
(contract-call? .smart-home-automation get-energy-bill 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### View Automation Rules
```clarity
(contract-call? .smart-home-automation get-automation-rule u1)
```

### Check DAO Proposals
```clarity
(contract-call? .smart-home-automation get-dao-proposal u1)
```

## 🛠️ Development

### Run Tests
```bash
clarinet test
```

### Check Contract
```bash
clarinet check
```

### Local Development
```bash
clarinet integrate
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │    │  Smart Contract │    │   DAO Voting    │
│                 │◄──►│                 │◄──►│                 │
│ • Thermostats   │    │ • NFT Ownership │    │ • Proposals     │
│ • Lights        │    │ • Access Control│    │ • Voting        │
│ • Security      │    │ • Energy Bills  │    │ • Execution     │
│ • Sensors       │    │ • Automation    │    │ • Governance    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Contract Functions

| Function | Description | Access |
|----------|-------------|---------|
| `register-device` | Register new IoT device | Public |
| `transfer-device` | Transfer device ownership | Owner |
| `grant-device-access` | Grant user access | Owner |
| `update-energy-usage` | Log energy consumption | Owner/Authorized |
| `pay-energy-bill` | Pay accumulated energy costs | Bill Owner |
| `create-automation-rule` | Create device automation | Owner/Authorized |
| `create-dao-proposal` | Submit governance proposal | Public |
| `vote-on-proposal` | Vote on DAO proposals | Public |

## 🔒 Security Features

- ✅ NFT-based ownership verification
- ✅ Role-based permission system  
- ✅ Secure STX payment integration
- ✅ Time-locked proposal execution
- ✅ Anti-double voting protection

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- 📧 Email: support@smarthome-dao.com
- 💬 Discord: [SmartHome DAO](https://discord.gg/smarthome-dao)
- 🐦 Twitter: [@SmartHomeDAO](https://twitter.com/smarthome-dao)

---

**Built with ❤️ on Stacks blockchain using Clarity smart contracts**
