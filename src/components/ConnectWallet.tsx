import { useStarknet, InjectedConnector } from '@starknet-react/core'

export function ConnectWallet() {
  const { account, connect } = useStarknet()

  if (account) {
    return <p>Account: {account}</p>
  }

  return <div>
    <p>Please connect your wallet</p>
    <button
      className="ml-2 rounded-md w-32 px-2 py-1 bg-slate-700 text-white"
      onClick={() => connect(new InjectedConnector())}>Connect</button>
  </div>
}
