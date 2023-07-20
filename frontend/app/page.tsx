import Image from 'next/image'
import AccountBalanceWalletTwoToneIcon from '@mui/icons-material/AccountBalanceWalletTwoTone';
import 'react-circular-progressbar/dist/styles.css';
import { ProgressBar} from './streamComponent';


export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="z-10 w-full max-w-5xl items-center justify-center justify-between font-mono text-sm lg:flex">
      </div>
      <div>
      <div className="rounded-md	 bg-white flex flex-row items-center justify-center p-3">
      <AccountBalanceWalletTwoToneIcon></AccountBalanceWalletTwoToneIcon>
        <h1>
          0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263
        </h1>
      </div>
      <ProgressBar/>
      <div className="rounded-md	bg-white flex flex-row items-center justify-center p-3">
        <h1 className="pr-5">
          13 hours, 13 minutes
        </h1>
        <h1 className = "text-lg font-semibold">
        Remaining
        </h1>
      </div>
      </div>
      <div className="relative flex place-items-center before:absolute before:h-[300px] before:w-[480px] before:-translate-x-1/2 before:rounded-full before:bg-gradient-radial before:from-white before:to-transparent before:blur-2xl before:content-[''] after:absolute after:-z-20 after:h-[180px] after:w-[240px] after:translate-x-1/3 after:bg-gradient-conic after:from-sky-200 after:via-blue-200 after:blur-2xl after:content-[''] before:dark:bg-gradient-to-br before:dark:from-transparent before:dark:to-blue-700 before:dark:opacity-10 after:dark:from-sky-900 after:dark:via-[#0141ff] after:dark:opacity-40 before:lg:h-[360px] z-[-1]">
      </div>
    </main>
  )
}
