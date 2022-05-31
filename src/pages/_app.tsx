import type { AppProps } from 'next/app'
import NextHead from 'next/head'
import { StarknetProvider } from '@starknet-react/core'
import '../styles/globals.css'


function MyApp({ Component, pageProps }: AppProps) {
  return (
    <StarknetProvider>
      <NextHead>
        <title>StarkNet ❤️ React</title>
      </NextHead>
      <Component {...pageProps} />
    </StarknetProvider>
  )
}

export default MyApp
