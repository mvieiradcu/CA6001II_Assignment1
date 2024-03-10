
# CA6001I_Assignment1

Welcome to our NFT Marketplace Project, a decentralized platform for buying, selling, and trading Non-Fungible Tokens (NFTs). The projects leverages blockchain technology to provide a secure and transparent environment for artists and collectors.

## Prerequisites

 Before you begin, ensure you have the following installed on your system: -  
**Node.js**: Required to run the project locally and manage dependencies. -  
**MetaMask**: A browser extension or mobile app that allows you to interact with the Ethereum blockchain. 

### Installing Node.js Visit 
[Node.js's official website](https://nodejs.org/) and download the latest LTS version for your operating system. Follow the installation instructions for your platform. To verify the installation, open a terminal or command prompt and run: 

```bash
node --version 
npm --version
```
### MetaMask
1.  Download MetaMask from the [official website](https://metamask.io/) or your browser's extension store.
2.  Follow the instructions to create a new wallet or import an existing one.
3.  Ensure you're connected to the Ethereum network or the specific blockchain network your project uses.


## Setup
Follow these steps to get your local environment set up:

1.  **Clone the Repository**
```bash
git clone https://github.com/mvieiradcu/CA6001II_Assignment1
cd [your-project-directory]
```

2.  **Install Ganache**
For Ganache installation follow the steps in the [Ganache](https://archive.trufflesuite.com/ganache/)
 official website  
3.  **Install Dependencies for the smart contract deploy**
Inside the project directory, run:
```bash
npm install
npx truffle migrate --network ganache --reset
```
4.  **Install the client dependencies**
Inside the client directory execute the commands below
```bash
npm install
npx truffle migrate --network ganache --reset
```
4.  **Start React application** 
```bash
npm start
```
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.


![alt text](assets/nft_marketplace.png)