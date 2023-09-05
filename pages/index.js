import React from "react";
import Layout from "./Layout";
import {Button, Grid} from "semantic-ui-react";
import Curve from "./Curve";
import Constant from "./Constant";
import Pool from "../Ethereum/Pool";
import web3 from "../Ethereum/web3";
import TokenLP from "../Ethereum/TokenLP";
import TokenLP_C from "../Ethereum/TokenLP_C";
import TokenA from "../Ethereum/TokenA";
import TokenB from "../Ethereum/TokenB";
class Index extends React.Component{
    state={
        errorMessage: '',
        loading: '',
        TokenA: '',
        TokenB: '',
        balanceLP:'',
        balanceLP_C:'',
        balanceA:'',
        balanceB:'',
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
        this.Reveal(); // 调用showRule函数
    }

    Reveal = async () => {
        try{
            const accounts = await web3.eth.getAccounts();
            const balanceLP = await TokenLP.methods.balanceOf(accounts[0]).call({from:accounts[0]});
            const balanceLP_C = await TokenLP_C.methods.balanceOf(accounts[0]).call({from:accounts[0]});
            const balanceA = await TokenA.methods.balanceOf(accounts[0]).call({from:accounts[0]});
            const balanceB = await TokenB.methods.balanceOf(accounts[0]).call({from:accounts[0]});
            this.setState({balanceLP:balanceLP});
            this.setState({balanceLP_C:balanceLP_C});
            this.setState({balanceA:balanceA});
            this.setState({balanceB:balanceB});
        }catch (err) {
            this.setState({ errorMessage: err.message });
        }
    }


    render() {
        return(
            <Layout>
                <div style={{display: "flex", alignItems: "center", marginBottom: "15px" }}>
                    <h4 style={{ marginRight: "10px" }}>
                        You have {this.state.balanceA} Token A, {this.state.balanceB} Token B and {this.state.balanceLP} Token LP for Constant product AMM and {this.state.balanceLP_C} Token LP for Curve-like AMM.
                    </h4>
                    <Button primary onClick={this.Reveal}>
                        Refresh
                    </Button>
                </div>
                <Grid columns={2}>
                    <Grid.Column>
                        <Constant/>
                    </Grid.Column>

                    <Grid.Column>
                        <Curve/>
                    </Grid.Column>
                </Grid>

            </Layout>
        )
    }
}

export default Index
