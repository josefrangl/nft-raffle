import * as React from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';

export default function Raffle() {
    const router = useRouter();
    const { raffleId } = router.query;
return (
    <div>
        <p>Raffle: {raffleId}</p>
    </div>
);

}

Raffle.getLayout = function getLayout(page) {
  return <Layout>{page}</Layout>
};