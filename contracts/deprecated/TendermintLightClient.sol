pragma solidity 0.6.4;

import "../lib/0.6.x/Memory.sol";
import "../interface/0.6.x/ILightClient.sol";
import "../interface/0.6.x/IParamSubscriber.sol";
import "../System.sol";

contract TendermintLightClient is ILightClient, System, IParamSubscriber {
    struct ConsensusState {
        uint64 preValidatorSetChangeHeight;
        bytes32 appHash;
        bytes32 curValidatorSetHash;
        bytes nextValidatorSet;
    }

    mapping(uint64 => ConsensusState) public lightClientConsensusStates;
    mapping(uint64 => address payable) public submitters;
    uint64 public initialHeight;
    uint64 public latestHeight;  // @dev deprecated
    bytes32 public chainID;  // @dev deprecated

    bytes public constant INIT_CONSENSUS_STATE_BYTES = hex"0";
    uint256 public constant INIT_REWARD_FOR_VALIDATOR_SER_CHANGE = 1e16;
    uint256 public rewardForValidatorSetChange;

    event initConsensusState(uint64 initHeight, bytes32 appHash);  // @dev deprecated
    event syncConsensusState(uint64 height, uint64 preValidatorSetChangeHeight, bytes32 appHash, bool validatorChanged);  // @dev deprecated
    event paramChange(string key, bytes value);  // @dev deprecated

    function init() external onlyNotInit {
        uint256 pointer;
        uint256 length;
        (pointer, length) = Memory.fromBytes(INIT_CONSENSUS_STATE_BYTES);

        /* solium-disable-next-line */
        assembly {
            sstore(chainID_slot, mload(pointer))
        }

        alreadyInit = true;
        rewardForValidatorSetChange = INIT_REWARD_FOR_VALIDATOR_SER_CHANGE;
    }

    function syncTendermintHeader(bytes calldata header, uint64 height) external onlyRelayer returns (bool) {
        revert("deprecated");
    }

    function isHeaderSynced(uint64 height) external view override returns (bool) {
        return submitters[height] != address(0x0) || height == initialHeight;
    }

    function getAppHash(uint64 height) external view override returns (bytes32) {
        return lightClientConsensusStates[height].appHash;
    }

    function getSubmitter(uint64 height) external view override returns (address payable) {
        return submitters[height];
    }

    function getChainID() external view returns (string memory) {
        bytes memory chainIDBytes = new bytes(32);
        assembly {
            mstore(add(chainIDBytes, 32), sload(chainID_slot))
        }

        uint8 chainIDLength = 0;
        for (uint8 j = 0; j < 32; ++j) {
            if (chainIDBytes[j] != 0) {
                ++chainIDLength;
            } else {
                break;
            }
        }

        bytes memory chainIDStr = new bytes(chainIDLength);
        for (uint8 j = 0; j < chainIDLength; ++j) {
            chainIDStr[j] = chainIDBytes[j];
        }

        return string(chainIDStr);
    }

    function updateParam(string calldata key, bytes calldata value) external override onlyInit onlyGov {
        revert("deprecated");
    }
}
