import { useStarknetCall } from '@starknet-react/core'
import { debug } from 'console'
import type { NextPage } from 'next'
import { useMemo } from 'react'
import { ConnectWallet } from '~/components/ConnectWallet'
import Game from '~/components/Game'
import { SendMoves } from '~/components/SendMoves'
import { TransactionList } from '~/components/TransactionList'
import { useGameContract } from '~/hooks/gameCountract'
import { useStarknet } from '@starknet-react/core'
import React, { useState } from 'react';

class InitState {
  pipeHeights: number[];

  constructor(pipeHeights: number[]) {
    this.pipeHeights = pipeHeights;
  }
}


const Home: NextPage = () => {
  const { account } = useStarknet()
  const { contract: gameContract } = useGameContract()
  const { data: contractInitState } = useStarknetCall({
    contract: gameContract,
    method: 'showInitState',
    args: [account],
  })

  const [moves, setMoves] = useState<Array<number>>([]);

  const setMovesCallback = (move: number) => {
    if (move == undefined)
      setMoves([]);
    else
      setMoves(list => [...list, move]);
  }

  const initState = useMemo(() => {
    if (contractInitState && contractInitState.length > 0) {
      let pipeHeights = contractInitState[3].toString().split(',').map(Number);
      let initState = new InitState(pipeHeights);
      console.log("yo: " + pipeHeights)
      return initState
    }
  }, [contractInitState])

  if (initState && account) {
    return (
      <div>
        <ConnectWallet />
        <h1>{moves.length} moves:</h1>
        <p id="movesText">{moves.join(",")}</p>
        <p>Address: {gameContract?.address}</p>
        <SendMoves moves={moves} />
        <Game pipeHeights={initState.pipeHeights} callback={setMovesCallback} />
        <TransactionList />
      </div>
    )
  }
  else {
    if (!account)
      return (
        <div>
          <ConnectWallet />
        </div>
      )
    else
      return (
        <div>
          <h2>Loading</h2>
        </div>
      )
  }

}

export default Home


