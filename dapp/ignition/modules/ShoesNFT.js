const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const ShoesNFTModule = buildModule("ShoesNFTModule", (m) => {
  const nft = m.contract("ShoesNFT");

  return { nft };
});

module.exports = ShoesNFTModule;
