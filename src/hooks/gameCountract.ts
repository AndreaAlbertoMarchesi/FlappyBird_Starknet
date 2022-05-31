import { useContract } from '@starknet-react/core'
import { Abi } from 'starknet'

import CounterAbi from '~/abi/counter.json'

export function useGameContract() {
  return useContract({
    abi: CounterAbi as Abi,
    address: '0x74954ae897932addeadd6f7e69d145ddb87664cd963ae68505381e41e8dc351',
  })
}
