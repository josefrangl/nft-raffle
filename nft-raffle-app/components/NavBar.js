
import * as React from 'react';
import AppBar from '@mui/material/AppBar';

import Button from '@mui/material/Button';

import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Link from '../src/Link';



import { connectWallet } from "../utils/common";
import { useAccount, useContracts } from "../contexts";

import Address from "./Address";


export default function NavBar() {
    const account = useAccount();
    const isMetamaskConnected = !!account;

    return (
        <AppBar
            position="static"
            color="default"
            elevation={0}
            sx={{ borderBottom: (theme) => `1px solid ${theme.palette.divider}` }}
        >
            <Toolbar sx={{ flexWrap: 'wrap' }}>
                <Typography variant="h6" color="inherit" noWrap sx={{ flexGrow: 1 }}>
                    NFT-Raffle
                </Typography>
                <nav>
                    <Link
                        variant="button"
                        color="text.primary"
                        href="/create-raffle"
                        sx={{ my: 1, mx: 1.5 }}
                    >
                        Create Raffle
                    </Link>
                    <Link
                        variant="button"
                        color="text.primary"
                        href="#"
                        sx={{ my: 1, mx: 1.5 }}
                    >
                        Enterprise
                    </Link>

                    {!isMetamaskConnected && (
                        <Button
                            style={{
                                border: 'none',
                                margin: 20,

                                borderRadius: 6,
                                boxShadow: '0 3px 5px 2px rgba(255, 105, 135, .3)',
                                cursor: 'pointer',
                                color: '#fff',
                                backgroundSize: '200%',
                                transition: '0.4s',
                                '&:hover': {
                                    backgroundPosition: 'right'
                                },
                                backgroundImage: 'linear-gradient(to left, #34495e, #9b59b6, #3498db)'
                            }}
                            href="#" variant="outlined" sx={{ my: 1, mx: 1.5 }}
                            onClick={connectWallet}
                        >
                            Connect Wallet
                        </Button>
                    )}
                </nav>

            </Toolbar>
        </AppBar>
    );
}