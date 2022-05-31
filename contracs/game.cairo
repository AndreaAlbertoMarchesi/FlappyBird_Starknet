# 0x4661c5e30d2f861aad428f20ee876c2b010479e9f6fa62ba4bbe17f9e8d34c3
%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import (
    unsigned_div_rem,
    assert_nn_le
)
from starkware.cairo.common.math_cmp import (
    is_in_range,
    is_le_felt
)

@contract_interface
namespace I_Token:
    func mint(to: felt, amount: Uint256):
    end
end

func mintToken{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(amount : Uint256, tokenAddress : felt, address : felt):
    I_Token.mint(tokenAddress,address,amount)
    return ()
end

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

@external
func validateGame{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, bitwise_ptr : BitwiseBuiltin*
        }(moves_len : felt, moves : felt*, tokenAddress : felt) -> (pos: Position):

    alloc_locals
    
    let (local address) = get_caller_address()

    let (state : State) = getInitState(address)

    let (local finalPos: Position) = validateGameHelper(moves_len, moves, state)

    mintToken(Uint256(finalPos.x*TOKEN_MULT, 0), tokenAddress, address)
    return(finalPos)
end

@view
func D_showFinalState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, bitwise_ptr : BitwiseBuiltin*
        }(moves_len : felt, moves : felt*, address : felt) -> (finalPos : Position):

    let (initState: State) = getInitState(address)

    return validateGameHelper(moves_len, moves, initState)
end

func validateGameHelper{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, bitwise_ptr : BitwiseBuiltin*
        }(moves_len : felt, moves : felt*, state : State) -> (finalPos : Position):
    
    if moves_len == 0:
        return (state.pos)
    else:
        let (isGameNotOver) = isAlive(state)
        
        if isGameNotOver == TRUE:
            let (next_state : State) = getNextState(state, moves[0])
            return validateGameHelper(moves_len-1, &moves[1], next_state)
        else:
            return (state.pos)
        end
    end
end

func getNextState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(s : State, move: felt) -> (state : State):
    alloc_locals
    let (local yVelocity) = getNextVelocity(s.yVelocity, move)

    let (next_pos : Position) = getNextPosition(s.pos, yVelocity)
    
    return (State(next_pos,yVelocity,s.pipesOffset))
end


@view
func getNextPosition{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(prev_pos : Position, yVelocity: felt) -> (pos : Position):

    return (Position(prev_pos.x + X_VELOCITY, prev_pos.y + yVelocity))
end

func getNextVelocity{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(prev : felt, move: felt) -> (yVelocity : felt):
    if move == 0:
        return (prev + GRAVITY)
    else:
        return (JUMP_VELOCITY)
    end
end

func isAlive{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(state : State) -> (bool : felt):
        alloc_locals
        let (local check_1) = isInsideBorders(state.pos)
        let (local check_2) = hasAvoidedPipe(state)
        return(check_1 * check_2)
end

@view
func isInsideBorders{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(pos : Position) -> (bool : felt):
        let (check_1) = is_in_range(pos.y,BOTTOM_Y,TOP_Y)
        return (check_1)
end

func hasAvoidedPipe{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(state : State) -> (bool : felt):
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
func showInitState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, bitwise_ptr : BitwiseBuiltin*
        }(address : felt) -> 
        (pos : Position, yVelocity : felt, pipesOffset_len : felt, pipesOffset : felt*):
    
    let (state : State) = getInitState(address)
    
    return (state.pos, state.yVelocity, PIPES_COUNT, state.pipesOffset)
end

func getInitState{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr, bitwise_ptr : BitwiseBuiltin*
        }(address : felt) -> (state : State):
    alloc_locals

    
    
    let (local value0) = getValueFromAddress(address, 1, MAX_PIPE_Y_VARIANCE)
    let (local value1) = getValueFromAddress(address, 2, MAX_PIPE_Y_VARIANCE)
    let (local value2) = getValueFromAddress(address, 3, MAX_PIPE_Y_VARIANCE)
    let (local value3) = getValueFromAddress(address, 4, MAX_PIPE_Y_VARIANCE)
    let (local value4) = getValueFromAddress(address, 5, MAX_PIPE_Y_VARIANCE)
    let (local value5) = getValueFromAddress(address, 6, MAX_PIPE_Y_VARIANCE)
    let (local value6) = getValueFromAddress(address, 7, MAX_PIPE_Y_VARIANCE)
    let (local value7) = getValueFromAddress(address, 8, MAX_PIPE_Y_VARIANCE)
    let (local value8) = getValueFromAddress(address, 9, MAX_PIPE_Y_VARIANCE)
    
    let (local pipesOffset : felt*) = alloc()
    
    assert pipesOffset[0] = value0
    assert pipesOffset[1] = value1
    assert pipesOffset[2] = value2
    assert pipesOffset[3] = value3
    assert pipesOffset[4] = value4
    assert pipesOffset[5] = value5
    assert pipesOffset[6] = value6
    assert pipesOffset[7] = value7
    assert pipesOffset[8] = value8
    
    return (State(Position(INIT_BIRD_X,INIT_BIRD_Y), INIT_Y_VELOCITY, pipesOffset))
end


@view
func getValueFromAddress{bitwise_ptr : BitwiseBuiltin*}(address : felt, addrChunk: felt, maxValue: felt) -> (value : felt):
    let andMask = maxValue - 1
    let shift = addrChunk * maxValue
    let addrShifted = address / shift
    let (value) = bitwise_and(andMask, addrShifted)
    return (value)
end

