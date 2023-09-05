import React from "react";
import {Container} from "semantic-ui-react";
import Head from "next/head";

//Head标签会自动把其中内容放到最上方，这部分代码是实现ui-react设置的CSS代码
//Header显示Header.js的内容
//children显示Layout标签中的内容,如index.js和new.js
export default props => {
    return(
        <Container>
            <Head>
                <link
                    async
                    rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/semantic-ui@2/dist/semantic.min.css"
                />
            </Head>
            <div>
                {props.children}
            </div>
        </Container>
    );
};

