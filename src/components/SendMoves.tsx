import { useStarknet, useStarknetInvoke } from '@starknet-react/core'
import React from 'react'
import { useGameContract } from '~/hooks/gameCountract'

interface SnakeProps {
  moves: number[]
}

export function SendMoves(props: SnakeProps) {
  const { account } = useStarknet()
  const { contract: counter } = useGameContract()
  const { loading, error, reset, invoke } = useStarknetInvoke({ contract: counter, method: 'validateGame' })

  if (!account) {
    return null
  }

  return (
    <button
      className="ml-2 rounded-md w-32 px-2 py-1 bg-slate-700 text-white"
      onClick={() => invoke({ args: [props.moves, "0x00e8dee7a500ea982c742a60c4498a666b706a23f2c8d8f89c9b5faeef3bc292"] })}
    >Send moves to contract</button>

  )
}
