"use client"
// ProgressBar.client.js
import { useState, useEffect } from 'react';
import { CircularProgressWithLabel } from './CircularProgressWithLabel';


export function Timer({startTimeStamp, endTimeStamp}: {startTimeStamp: number, endTimeStamp: number}) {

  const calculateRemainingTime = (currentTime: number) => {
    const remainingPeriod = endTimeStamp - currentTime;
    return {
      remainingPeriod,
      hoursRemaining: Math.floor(remainingPeriod / (1000 * 60 * 60)),
      minutesRemaining: Math.floor((remainingPeriod % (1000 * 60 * 60)) / (1000 * 60)),
      secondsRemaining: Math.floor((remainingPeriod % (1000 * 60)) / 1000)
    };
  }

  const initialRemainingTime = calculateRemainingTime(startTimeStamp)
  const [remainingTime, setRemainingTime] = useState(initialRemainingTime);

  useEffect(() => {
    const intervalId = setInterval(() => {
      setRemainingTime(calculateRemainingTime(Date.now()));
    }, 1000);
    return () => clearInterval(intervalId);
  }, []);

  return (
    <div className="rounded-md	bg-white flex flex-row items-center justify-center p-3">
        <h1 className="pr-5">
        {remainingTime.hoursRemaining} Hours {remainingTime.minutesRemaining} minutes {remainingTime.secondsRemaining} seconds
        </h1>
        <h1 className = "text-lg font-semibold">
         Remaining
        </h1>
    </div>
  );
}

export default Timer;



