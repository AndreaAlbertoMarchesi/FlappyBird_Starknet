import { useEffect, useState } from "react"
import useLocalStorage from "../../hooks/useLocalStorage"

interface InfoScoreProps {
    score: number
    moves: number[]
}

export default function InfoScore(props: InfoScoreProps) {
    const [bestScore, setBestScore] = useLocalStorage("bestScore", 0)
    useEffect(() => {
        if (props.score > bestScore) {
            setBestScore(props.score)
        }
    }, [props.score])


    return (
        <div className="opacity-30 p-2">
            <p className="font-bold">Current Score: {props.score}</p>
            <p className="font-bold">Best Score: {bestScore}</p>
            <p className="font-bold">Moves: {props.moves.toString()}</p>

        </div>
    )
}