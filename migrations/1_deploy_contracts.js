const TokenA = artifacts.require('TokenA');
const TokenB = artifacts.require('TokenB');
const TokenLP = artifacts.require('TokenLP');
const LP = artifacts.require('LP');
const Curve = artifacts.require('Curve');
module.exports = async function (deployer) {
    await deployer.deploy(TokenA);
    await deployer.deploy(TokenB);
    await deployer.deploy(TokenLP);
    await deployer.deploy(LP);

};
