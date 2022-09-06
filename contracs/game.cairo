# 0x2701ec5cb4fbdab7714c5a9393a6a31999599a9f643d469df37962d1b533776
%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bitwise import bitwise_and
#delete bitwise
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (
    unsigned_div_rem,
    assert_nn_le,
    split_felt
)
from starkware.cairo.common.math_cmp import (
    is_in_range,
    is_le_felt
)
# CONSTANTS
const PIPE_START_X = 100
const PIPE_END_X = 120
const BOTTOM_Y = 0
const TOP_Y = 100
const JUMP_VELOCITY = 6
const X_VELOCITY = 4
const GRAVITY = -1
const MAX_PIPE_Y_VARIANCE = 40
const PIPES_COUNT = 8
const PIPE_GAP_Y = 60
const INIT_Y_VELOCITY = 0
const INIT_BIRD_X = 0
const INIT_BIRD_Y = 40
const MIN_X_TO_WIN = 500
const TOKEN_MULT = 1000000000

# GAME STATE STRUCT

struct Position:
    member x : felt
    member y : felt
end

struct State:
    member pos : Position
    member yVelocity : felt
    member pipesOffset: felt*
end


@storage_var
func isMember(user : felt) -> (res : felt):
end

@view
func get_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(user : felt) -> (res : felt):
    let (res) = isMember.read(user=user)
    return (res)
end

@external
func validateGame{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
        }(moves_len : felt, moves : felt*) -> (pos: Position):

    alloc_locals
    
    let (local address) = get_caller_address()

    let (initState : State) = getInitState(address)

    let (local finalState: State) = getFinalState(moves_len, moves, initState)

#    assert_nn_le(finalPos.x, 200)
    #isMember.write(address, TRUE)
    isMember.write(address, finalState.pos.x)
    return(finalState.pos)
end

@view
func D_showFinalState{
        syscall_ptr : felt*, range_check_ptr
        }(moves_len : felt, moves : felt*, address : felt) -> (finalPos : Position):

    let (initState: State) = getInitState(address)
    let (finalState: State) = getFinalState(moves_len, moves, initState)
    return (finalState.pos)
end

func getFinalState{syscall_ptr : felt*, range_check_ptr
        }(moves_len : felt, moves : felt*, state : State) -> (finalState : State):

    if moves_len == 0:
        return (state)
    else:
        let (isFinal) = isStateFinal(state)
        
        if isFinal == TRUE:
            return (state)
        else:
            let (next_state : State) = transitionFunction(state, moves[0])
            return getFinalState(moves_len-1, &moves[1], next_state)
        end
    end
end

func transitionFunction{syscall_ptr : felt*, range_check_ptr
        }(s : State, move: felt) -> (state : State):
    alloc_locals
    
    let (local yVelocity) = getNextVelocity(s.yVelocity, move)

    let (next_pos : Position) = getNextPosition(s.pos, yVelocity)
    
    return (State(next_pos,yVelocity,s.pipesOffset))
end


func getNextPosition{syscall_ptr : felt*, range_check_ptr}(prev_pos : Position, yVelocity: felt)
         -> (pos : Position):

    return (Position(prev_pos.x + X_VELOCITY, prev_pos.y + yVelocity))
end

func getNextVelocity{syscall_ptr : felt*, range_check_ptr}(prev : felt, move: felt) -> (yVelocity : felt):
    if move == 0:
        return (prev + GRAVITY)
    else:
        return (JUMP_VELOCITY)
    end
end

func isStateFinal{
        syscall_ptr : felt*, range_check_ptr}(state : State) -> (bool : felt):
        alloc_locals
        let (local check_1) = isInsideBorders(state.pos)
        let (local check_2) = hasAvoidedPipe(state)
        let isAlive = check_1 * check_2
        if isAlive == TRUE:
            return (FALSE)
        else:
            return (TRUE)
        end
end

func isInsideBorders{
        syscall_ptr : felt*, range_check_ptr}(pos : Position) -> (bool : felt):
        let (check_1) = is_in_range(pos.y,BOTTOM_Y,TOP_Y)
        return (check_1)
end

func hasAvoidedPipe{
        syscall_ptr : felt*, range_check_ptr}(state : State) -> (bool : felt):
    alloc_locals
    let (local passedPipesCount, x) = unsigned_div_rem(state.pos.x, PIPE_END_X)
    let (isInPipeRange) = is_in_range(x, PIPE_START_X, PIPE_END_X)

    if isInPipeRange == TRUE:
    
        let (_, pipeIndex) = unsigned_div_rem(passedPipesCount, PIPES_COUNT)
        let pipeOffset = state.pipesOffset[pipeIndex]
        let (isInSafeRange) = is_in_range(state.pos.y, 0 + pipeOffset, PIPE_GAP_Y + pipeOffset)
        return (isInSafeRange)
    else:
        return (TRUE)
    end
end

@view
func showInitState{syscall_ptr : felt*, range_check_ptr}(address : felt) -> 
        (pos : Position, yVelocity : felt, pipesOffset_len : felt, pipesOffset : felt*):
    
    let (state : State) = getInitState(address)
    
    return (state.pos, state.yVelocity, PIPES_COUNT, state.pipesOffset)
end

func getInitState{syscall_ptr : felt*, range_check_ptr}(address : felt) -> (state : State):

    let (_, pipesOffset : felt*) = getValuesFromSeed(address, MAX_PIPE_Y_VARIANCE, 8)
    
    return (State(Position(INIT_BIRD_X,INIT_BIRD_Y), INIT_Y_VELOCITY, pipesOffset))
end

@view
func getValuesFromSeed{range_check_ptr}(seed: felt, maxValue: felt, howMany: felt) -> (values_len: felt, values : felt*):
    alloc_locals
    let (local accumulator : felt*) = alloc()
    return getValuesFromSeedHelper(seed, maxValue, howMany, 0, accumulator)
end

func getValuesFromSeedHelper{range_check_ptr}(seed: felt, maxValue: felt, howMany: felt, acc_len: felt, acc: felt*) -> (values_len: felt, values : felt*):
    alloc_locals
    if acc_len == howMany:
        return (acc_len, acc)
    end
    let (_, seed_lowerHalf) = split_felt(seed)
    let (_, local value) = unsigned_div_rem(seed_lowerHalf, maxValue)
    assert acc[acc_len] = value
    let newSeed = seed * seed
    return getValuesFromSeedHelper(newSeed, maxValue, howMany, acc_len + 1, acc)
end
