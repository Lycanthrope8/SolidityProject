# Patient Management System

## Description

This Patient Management System is a blockchain-based application designed to manage patient information securely and efficiently. It utilizes Ethereum smart contracts to ensure transparency and integrity in the handling of patient data, including registration, appointment scheduling, and vaccination tracking.

## Features

- Patient registration and information management
- Doctor scheduling and appointment booking
- Vaccination status tracking
- Secure patient data handling with Ethereum smart contracts

## Prerequisites

Before setting up the project, ensure you have the following installed:

- Node.js
- npm (Node Package Manager)
- Truffle Suite
- Ganache (for a personal Ethereum blockchain)

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Lycanthrope8/SolidityProject.git
   cd SolidityProject
   ```
2. **Install dependencies**

   ```bash
   npm install
   ```
3. **Compile smart contracts**

   ```bash
   truffle compile --all
   ```
4. **Deploy smart contracts**

   ```bash
   truffle migrate --reset
   ```
5. **Run the development server**

   ```bash
   npm run dev
   ```

## Usage

After running the development server, the application will be available at `http://localhost:3000`. Navigate to this URL in a web browser with MetaMask installed to interact with the system.

## Configuration

Ensure that your MetaMask is connected to your local Ganache blockchain by setting up a custom RPC with the IP and port typically found in Ganache (e.g., `http://127.0.0.1:7545`).

## Contributing

Contributions to the project are welcome! Please fork the repository and submit a pull request with your features or fixes.

## License

Distributed under the MIT License. See `LICENSE` for more information.
