interface BirdPos {
    birdPos: number[]
    pipeHeights: number[]
}
export default function Food(props: BirdPos) {
    const xPipeSpawn = 100
    const xBeforeRespawn = 120

    const passedPipes = Math.floor(props.birdPos[0] / xBeforeRespawn)
    const pipeIndex = passedPipes % props.pipeHeights.length
    const yPipeBase = -100 + props.pipeHeights[pipeIndex]
    const pipeHeight = 130

    const pipe_0_bot = {
        left: `${xPipeSpawn - props.birdPos[0] % xBeforeRespawn}%`,
        bottom: `${(yPipeBase)}%`
    }
    const pipe_0_top = {
        left: `${xPipeSpawn - props.birdPos[0] % xBeforeRespawn}%`,
        bottom: `${(yPipeBase + pipeHeight)}%`
    }
    return (
        <div>
            <div className="obstacle" style={pipe_0_bot}></div>
            <div className="topObstacle" style={pipe_0_top}></div>
        </div>
    )
}