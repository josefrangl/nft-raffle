import * as React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Link from '../src/Link';
import Layout from '../components/Layout';

import {
  networkName,
  getEthereumObject,
  setupEthereumEventListeners,
  getSignedContract,
  getCurrentAccount,
} from "../utils/common";

import { TextArea, DatePicker, Space, Form, Input, InputNumber, Button } from 'antd';

// import { DatePickerProps, RangePickerProps } from 'antd/es/date-picker';

const { RangePicker } = DatePicker;
import 'antd/dist/antd.css';



import { useContracts } from "../contexts";

const layout = {
  labelCol: {
    span: 10,
  },
  wrapperCol: {
    span: 10,
  },
};
/* eslint-disable no-template-curly-in-string */

const validateMessages = {
  required: '${label} is required!',
  types: {
    email: '${label} is not a valid email!',
    number: '${label} is not a valid number!',
  },
  number: {
    range: '${label} must be between ${min} and ${max}',
    min: '${label} must be ${min} or above'
  },
};

const dtConfig = {
  rules: [
    {
      type: 'object',
      required: true,
      message: 'Please select time!',
    },
  ],
};

const formResult = {};
const nftContract = {};


export default function CreateRaffle() {


  const { dcWarriorsContract } = useContracts();

  const load = async (contract) => {
    const ethereum = getEthereumObject();
    if (!ethereum) {
      return;
    }

    setupEthereumEventListeners(ethereum);

    const nftContract = getSignedContract(
      contract,
      contract.abi
    );


    if (nftContract) return;

    const currentAccount = await getCurrentAccount();
    console.log('lol', currentAccount, nftContract);
    setContracts({ nftContract });
    setAccount(currentAccount);
  };


  const authorizeContract = async (nftContract, address) => {


    try {
      const txn = await dcWarriorsContract.mint(address);
      await txn.wait();
      toastSuccessMessage(`🦄 NFT was successfully minted!`);
    } catch (e) {
      console.log(e);
      toastErrorMessage(
        `Couldn't mint nft. Please check the address or try again later.`
      );
    }
  };
  const onFinishContract = async (values) => {
    console.log(values);
    nftContract = values;
    console.log('nft', nftContract);
    await load(nftContract.nft.nftContract);

  };
  const onFinish = (values) => {
    console.log(values);
    formResult = values;
    console.log('fr', formResult);
  };


  return (
    <Container maxWidth="sm">
      <Box sx={{ my: 4 }}>
        <Form {...layout} name="nest-messages" onFinish={onFinishContract} validateMessages={validateMessages} labelWrap>
          <Form.Item
            name={['nft', 'nftContract']}
            label="Contract Address"
            rules={[
              {
                required: true,
              },
              {
                pattern: /^0x[a-fA-F0-9]{40}$/,
                message: 'Please enter a valid address',
              }
            ]}
          >
            <Input.TextArea autoSize={{ maxRows: 3 }} />
          </Form.Item>
          <Form.Item
            name={['nft', 'nftTokenId']}
            label="Token ID"
            rules={[
              {
                type: 'number',
                required: true,
              },
            ]}
          >
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item wrapperCol={{ ...layout.wrapperCol, offset: 8 }}>
            <Button type="primary" htmlType="submit">
              Authorize NFT Contract
            </Button>
          </Form.Item>
        </Form>
        <Form {...layout} name="nest-messages" onFinish={onFinish} validateMessages={validateMessages} labelWrap>
          <Form.Item
            name={['raffle', 'numberOfTickers']}
            label="Min Number of Tickets"
            rules={[
              {
                type: 'number',
                min: 1,
              },
            ]}
          >
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name={['raffle', 'price']}
            label="Price per Ticket"
            rules={[
              {
                type: 'number',
                min: 0.001,
              }
            ]}
          >
            <InputNumber addonAfter="ETH" style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name={['raffle', 'startTime']}
            label="Select Date and Time Start"
            {...dtConfig}
          >
            <DatePicker showTime format="YYYY-MM-DD HH:mm" style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name={['raffle', 'duration']}
            label="Select raffle duration"
            rules={[
              {
                type: 'number',
                min: 1,
                max: 30,
              }]}
          >
            <InputNumber addonAfter="days" style={{ width: '100%' }} />
          </Form.Item >
          <Form.Item wrapperCol={{ ...layout.wrapperCol, offset: 8 }}>
            <Button type="primary" htmlType="submit">
              Submit
            </Button>
          </Form.Item>
        </Form>
      </Box>
    </Container >
  );
}

CreateRaffle.getLayout = function getLayout(page) {
  return <Layout>{page}</Layout>
};