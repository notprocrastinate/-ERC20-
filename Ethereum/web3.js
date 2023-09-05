import Web3 from "web3";

let web3;
if (typeof window !== 'undefined' && window.web3 !== 'undefined'){
    // 说明在浏览器里切用户启动了metamask
    web3 = new Web3(window.web3.currentProvider)
}else {
    // 在服务器中或者用户没有启动metamask,需要手动配置provider（不能用metamask的了）
    const provider = new Web3.providers.HttpProvider(
        //'https://goerli.infura.io/v3/3a24c3ea67b048f2801c4f1bc2780df3'
        'HTTP://127.0.0.1:8545'
    );
    web3 = new Web3(provider);
}

export default web3;