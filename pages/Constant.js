import React from "react";
import Layout from "./Layout";
import TokenA from "../Ethereum/TokenA.js";
import TokenB from "../Ethereum/TokenB.js";
import TokenLP from "../Ethereum/TokenLP.js";
import Pool from "../Ethereum/Pool.js";
import {Button, Dropdown, Input} from "semantic-ui-react";
import web3 from "../Ethereum/web3";

const options = [
    { key: 'TokenA', text: 'TokenA', value: 'TokenA' },
    { key: 'TokenB', text: 'TokenB', value: 'TokenB' },
]


class Index extends React.Component{
    state={
        errorMessage: '',
        loading: '',
        loading2: '',
        loading3: '',
        TokenA: '',
        TokenB: '',
        balanceLP:'***',
        balanceA:'***',
        balanceB:'***',
        TokenAInPool:'0',
        TokenBInPool:'0',
        TokenA_S: '',  //swap
        TokenB_S: '',
        UserOption:'TokenA',
        SwapOption:'TokenB',  //用于显示交换的币种，与用户选择相反
        SwapAmount:'',
        GetAmount:'',
        MinimumOut:'0',
        test:'',
        RoH:'H'  //Reveal or Hide
    }

    componentDidMount() {
        this.GetTokens(); // 调用showRule函数
    }

    GetTokens = async () =>{
        const results = await Pool.methods.getReserves().call();
        this.setState({TokenAInPool:results[0]});
        this.setState({TokenBInPool:results[1]});
    }

    Mint = async(event) =>{
        event.preventDefault();
        this.setState({errorMessage:''});
        this.setState({loading:true});
        try {
            const accounts = await web3.eth.getAccounts();
            await TokenA.methods.approve(Pool.options.address,this.state.TokenA).send({from:accounts[0]});
            await TokenB.methods.approve(Pool.options.address,this.state.TokenB).send({from:accounts[0]});
            const balance = await Pool.methods.mint(accounts[0]).call({from:accounts[0]});
            await Pool.methods.mint(accounts[0]).send({from:accounts[0]});
            alert("You have successfully mint " + balance + " LP tokens!");
            this.setState({SwapAmount:''});
            this.setState({GetAmount:''});
            await this.GetTokens();
        }catch(err) {
            this.setState({errorMessage:err.message});
        }
        this.setState({loading:false});
    }

    Swap = async(event) =>{
        event.preventDefault();
        this.setState({loading2:true});
        this.setState({errorMessage:''});
        try {
            let tokenType;
            let changedType;
            const accounts = await web3.eth.getAccounts();
            if(this.state.UserOption === 'TokenA'){
                tokenType = '';
                changedType = ' Token B';
                await TokenA.methods.approve(Pool.options.address,this.state.SwapAmount).send({from:accounts[0]});
            }else {
                tokenType = 'true';
                changedType = ' Token A';
                await TokenB.methods.approve(Pool.options.address,this.state.SwapAmount).send({from:accounts[0]});
            }
            const TokenChanged = await Pool.methods.swap(this.state.SwapAmount,tokenType,this.state.MinimumOut,accounts[0]).call({from:accounts[0]});
            await Pool.methods.swap(this.state.SwapAmount,tokenType,this.state.MinimumOut,accounts[0]).send({from:accounts[0]});
            alert("You have successfully changed " + TokenChanged + changedType);
            this.setState({SwapAmount:''});
            this.setState({GetAmount:''});
            await this.GetTokens();
        }catch(err) {
            this.setState({errorMessage:err.message});
        }
        this.setState({loading2:false});
    }

    handleInputChange = async (value) => {
        this.setState({ SwapAmount: value});
        this.setState({ errorMessage:''});
        try{
            const accounts = await web3.eth.getAccounts();
            let tokenType;
            //Only empty can be use as ‘false’,'false' will use as 'true'
            if(this.state.UserOption === 'TokenA'){
                this.setState({ SwapOption:'TokenB'})
                tokenType = ''
            }else {
                this.setState({ SwapOption:'TokenA'})
                tokenType = 'true'
            }
            const getAmount = await Pool.methods.trySwap(this.state.SwapAmount,tokenType).call({from:accounts[0]});
            this.setState({GetAmount:getAmount.toString()});
        }catch (err) {
            if(err.message === 'invalid BigNumber string (argument="value", value="", code=INVALID_ARGUMENT, version=bignumber/5.7.0)'){
            }else{
                this.setState({ errorMessage: err.message });
            }
        }
    };

    handleOptions =(e,data) => {
        this.setState({ UserOption: data.value });
        this.handleInputChange(this.state.SwapAmount);
    };

    Burn = async (event) => {
        this.setState({loading3:true});
        this.setState({errorMessage:''});
        event.preventDefault();
        try{
            const accounts = await web3.eth.getAccounts();
            const result = await Pool.methods.burn(accounts[0]).call({from:accounts[0]});
            const AmountA = result[0];
            const AmountB = result[1];
            await Pool.methods.burn(accounts[0]).send({from:accounts[0]});
            alert("You have successfully withdrew " + AmountA + " Token A and " + AmountB +" Token B.");
        }catch (err) {
            this.setState({ errorMessage: err.message });
        }
        this.setState({SwapAmount:''});
        this.setState({GetAmount:''});
        await this.GetTokens();
        this.setState({loading3:false});
    }

    render() {
        return(
            <Layout>
                <h1>Constant product AMM!</h1>

                <div style={{display: 'flex', flexDirection: 'column'}}>
                    <Input
                        label={"TokenA"}
                        value={this.state.TokenA}
                        onChange={event => this.setState({ TokenA: event.target.value })}
                    />
                </div>
                <div style={{display: 'flex', flexDirection: 'column',marginBottom: '10px'}}>
                    <Input
                        label={"TokenB"}
                        value={this.state.TokenB}
                        onChange={event => this.setState({ TokenB: event.target.value })}
                    />
                </div>
                <Button loading = {this.state.loading} primary onClick={this.Mint}>Inject Liquidity</Button>

                <h3>There are {this.state.TokenAInPool} Token A and {this.state.TokenBInPool} Token B in the pool.</h3>

                <div style={{ display: 'flex', alignItems: 'center' }}>
                    <div style={{ marginRight: '10px', fontSize: '20px' }}>I want to swap:</div>
                    <Input
                        label={
                            <Dropdown
                                defaultValue='TokenA'
                                options={options}
                                onChange={(event, data) => this.handleOptions(event,data)}
                            />
                        }
                        labelPosition='right'
                        value={this.state.SwapAmount}
                        onChange={(event) => this.handleInputChange(event.target.value)}
                    />
                </div>

                <div style={{ marginBottom: '10px', fontSize: '20px' }}>You will get: {this.state.GetAmount} {this.state.SwapOption}</div>

                <div style={{display: "flex", alignItems: "center", marginBottom: "15px" }}>
                    <Input
                        label={
                            'MinimumOut'
                        }
                        value={this.state.MinimumOut}
                        onChange={event => this.setState({ MinimumOut: event.target.value })}
                    />
                    <Button loading = {this.state.loading2} primary onClick={this.Swap}>Swap</Button>
                </div>

                <br />
                <Button loading = {this.state.loading3} primary onClick={this.Burn}>Withdraw Tokens</Button>

                <div>{this.state.errorMessage}</div>

            </Layout>
        )
    }
}

export default Index
