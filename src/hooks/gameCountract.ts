import { useContract } from '@starknet-react/core'
import { Abi } from 'starknet'

import CounterAbi from '~/abi/counter.json'
/*
$0.018950
$0.026530
*/
export function useGameContract() {
  return useContract({
    abi: CounterAbi as Abi,
    address: '0x2701ec5cb4fbdab7714c5a9393a6a31999599a9f643d469df37962d1b533776',//'0x74954ae897932addeadd6f7e69d145ddb87664cd963ae68505381e41e8dc351',
  })
}
