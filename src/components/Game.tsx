import React from "react";
import Food from "./Game/Food";
import Snake from "./Game/Snake";



interface AppProps {
    pipeHeights: number[]
    callback: Function
}

interface GameState {
    pipeHeights: number[],
    fps: number,
    pause: boolean,
    play: boolean,
    gameOver: String,
    direction: String,
    birdPos: number[]
    moves: number[]
    callback: Function
    yVelocity: number
}

const minY = 0
const maxY = 100
var initState: GameState;


class Game extends React.Component<AppProps, GameState> {


    constructor(props: any) {
        super(props);
        initState = {
            pipeHeights: props.pipeHeights,
            fps: 15,//70,
            pause: false,
            play: false,
            gameOver: "",
            direction: 'RIGHT',
            birdPos: [0, 40],
            moves: [],
            callback: props.callback,
            yVelocity: 0,
        }
        this.state = initState
        console.log(this.state.pipeHeights.length)
    }

    componentDidMount(): void {
        let frameDelay = 1000 / this.state.fps;
        setInterval(this.moveBird, frameDelay)
        document.onkeydown = this.onKeyDown;
    }

    onKeyDown = (e: any) => {
        e = e || window.event;

        if (!e.repeat)
            this.setState({
                yVelocity: 7,
            })
    }


    moveBird = () => {

        if (!this.state.pause && this.state.play) {
            var moves = this.state.moves

            this.setState({
                yVelocity: this.state.yVelocity - 1,
            })
            if (this.state.yVelocity == 6)
                moves.push(1)
            else
                moves.push(0)

            if (this.isAlive()) {

                let pos: number[] = this.state.birdPos
                pos = [Number(pos[0]) + 4, Number(pos[1]) + this.state.yVelocity]


                this.state.callback(moves[moves.length - 1])

                this.setState({
                    birdPos: pos,
                    moves: moves
                })
            }
            else
                this.onGameOver()
        }
    }

    isAlive() {
        return this.hasAvoidedPipe() && this.isInsideBorders()
    }

    hasAvoidedPipe() {
        const pos = this.state.birdPos;
        const passedPipes = Math.floor(pos[0] / 120)
        const pipeIndex = passedPipes % this.state.pipeHeights.length
        const pipeHeight = this.state.pipeHeights[pipeIndex]
        console.log(pipeHeight)

        const isInPipeRange = pos[0] % 120 >= 100
        if (isInPipeRange) {
            const isInSafeRange = pos[1] >= pipeHeight && pos[1] < pipeHeight + 30

            if (!isInSafeRange)
                return false
        }
        return true
    }

    isInsideBorders() {
        let pos = this.state.birdPos;
        return pos[1] < maxY && pos[1] >= minY
    }


    onGameOver() {
        this.setState({
            pipeHeights: initState.pipeHeights,
            fps: 70,
            pause: false,
            play: false,
            gameOver: `Game Over! Your Score was ${this.state.birdPos} Try Again`,
            direction: 'RIGHT',
            birdPos: initState.birdPos,
            moves: initState.moves,
            yVelocity: 0,
        });
    }

    onGameStart() {
        this.setState({ play: true, gameOver: "" })
        this.state.callback(undefined)
    }

    render() {
        return (
            <div>
                <div className="flex my-2 justify-center">
                    <button className="rounded-md w-32 px-2 py-1 bg-slate-700 text-white" onClick={() => {
                        if (this.state.play)
                            this.onGameOver()
                        else this.onGameStart()
                    }}>{this.state.play ? "End Game" : "Play Game"}</button>
                    {this.state.play ?
                        <button className="ml-2 rounded-md w-32 px-2 py-1 bg-slate-700 text-white" onClick={() => { this.setState(this.state.pause ? { pause: false } : { pause: true }) }}>
                            {this.state.pause ? "Return Game" : "Pause Game"}</button>
                        :
                        <></>
                    }
                </div>
                {
                    <div className={`game-area ${this.state.pause ? "bg-gray-500" : "bg-gray-200"} rounded-lg`}>
                        <Snake birdPos={this.state.birdPos} />
                        <Food birdPos={this.state.birdPos} pipeHeights={this.state.pipeHeights} />
                        <p>{this.state.gameOver}</p>

                    </div>
                }
            </div>
        )
    }
}

export default Game;