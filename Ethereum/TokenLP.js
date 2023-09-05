import web3 from "./web3";
import Contract from '../build/contracts/TokenLP.json'
    const Instance = new web3.eth.Contract(Contract.abi, '0x0A72cc1c982a8F0aE56E966BFe5dEA25CE885649');

export default Instance;



