"use client"
// ProgressBar.client.js
import { useState, useEffect } from 'react';
import { CircularProgressWithLabel } from './CircularProgressWithLabel';


export function ProgressBar({startingValue, periodicAmount}: {startingValue: number, periodicAmount: number}) {
  const [value, setValue] = useState(startingValue);

  useEffect(() => {
    const interval = setInterval(() => {
      setValue(oldValue => {
        if (oldValue >= 100) {
          clearInterval(interval);
          return oldValue;
        } else {
          return oldValue + periodicAmount;
        }
      });
    }, 200); // Update every second

    return () => clearInterval(interval); // Clean up on unmount
  }, []);

  return (
    <div className="flex items-center justify-center p-10">
      <CircularProgressWithLabel variant="determinate" value={value} size={300} thickness={2.5}/>
    </div>
  );
}

export default ProgressBar;
