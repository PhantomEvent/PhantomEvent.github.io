
// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File: @openzeppelin/contracts/access/Ownable.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File: @openzeppelin/contracts/security/ReentrancyGuard.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File: @openzeppelin/contracts/utils/Address.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File: @openzeppelin/contracts/utils/Context.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File: @positionex/matching-engine/contracts/interfaces/IAutoMarketMakerCore.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/amm/Liquidity.sol";
import "./IGetFeeShareAMM.sol";

interface IAutoMarketMakerCore {
    struct AddLiquidity {
        uint128 baseAmount;
        uint128 quoteAmount;
        uint32 indexedPipRange;
    }

    /// @notice Add liquidity and mint the NFT
    /// @param params Struct AddLiquidity
    /// @dev Depends on data struct with base amount, quote amount and index pip
    /// calculate the liquidity and increase liquidity at index pip
    /// @return baseAmountAdded the base amount will be added
    /// @return quoteAmountAdded the quote amount will be added
    /// @return liquidity calculate from quote and base amount
    /// @return feeGrowthBase tracking growth base
    /// @return feeGrowthQuote tracking growth quote
    function addLiquidity(
        AddLiquidity calldata params
    )
        external
        returns (
            uint128 baseAmountAdded,
            uint128 quoteAmountAdded,
            uint256 liquidity,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote
        );

    /// @notice the struct for remove liquidity avoid deep stack
    struct RemoveLiquidity {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
    }

    /// @notice Remove liquidity in index pip of nft
    /// @param params Struct Remove liquidity
    /// @dev remove liquidity at index pip and decrease the data of liquidity info
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    function removeLiquidity(
        RemoveLiquidity calldata params
    ) external returns (uint128 baseAmount, uint128 quoteAmount);

    /// @notice estimate amount receive when remove liquidity in index pip
    /// @param params struct Remove liquidity
    /// @dev calculate amount of quote and base
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    /// @return liquidityInfo newest of liquidity info
    function estimateRemoveLiquidity(
        RemoveLiquidity calldata params
    )
        external
        view
        returns (
            uint128 baseAmount,
            uint128 quoteAmount,
            Liquidity.Info memory liquidityInfo
        );

    /// @notice get liquidity info of any index pip range
    /// @param index want to get info
    /// @dev load data from storage and return
    /// @return sqrtMaxPip sqrt of max pip
    /// @return sqrtMinPip sqrt of min pip
    /// @return quoteReal quote real of liquidity of index
    /// @return baseReal base real of liquidity of index
    /// @return indexedPipRange index of liquidity info
    /// @return feeGrowthBase the growth of base
    /// @return feeGrowthQuote the growth of base
    /// @return sqrtK sqrt of k=quoteReal*baseReal,
    function liquidityInfo(
        uint256 index
    )
        external
        view
        returns (
            uint128 sqrtMaxPip,
            uint128 sqrtMinPip,
            uint128 quoteReal,
            uint128 baseReal,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            uint128 sqrtK
        );

    /// @notice get current index pip range
    /// @dev load current index pip range from storage
    /// @return The current pip range
    function pipRange() external view returns (uint128);

    /// @notice get the tick space for external generate orderbook
    /// @dev load current tick space from storage
    /// @return the config tick space
    function tickSpace() external view returns (uint32);

    /// @notice get current index pip range
    /// @dev load current current index pip range from storage
    /// @return the current index pip range
    function currentIndexedPipRange() external view returns (uint256);

    /// @notice get percent fee will be share when market order fill
    /// @dev load config fee from storage
    /// @return the config fee
    function feeShareAmm() external view returns (uint32);

    /// @notice get spot factory
    /// @return the config fee
    function spotFactory() external view returns (IGetFeeShareAMM);
}


// File: @positionex/matching-engine/contracts/interfaces/IFee.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IFee {
    /// @notice decrease the fee base
    /// @param baseFee will be decreased
    /// @dev minus the fee base funding
    function decreaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice decrease the fee quote
    /// @param quoteFee will be decreased
    /// @dev minus the fee quote funding
    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice increase the fee base
    /// @param baseFee will be decreased
    /// @dev plus the fee base funding
    function increaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice increase the fee quote`
    /// @param quoteFee will be decreased
    /// @dev plus the fee quote funding
    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice reset the fee funding to zero when Position claim fee
    /// @param baseFee will be decreased
    /// @param quoteFee will be decreased
    /// @dev reset baseFee and quoteFee to zero
    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    /// @notice get the fee base funding and fee quote funding
    /// @dev load amount quote and base
    /// @return baseFeeFunding and quoteFeeFunding
    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);
}


// File: @positionex/matching-engine/contracts/interfaces/IGetFeeShareAMM.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IGetFeeShareAMM {
    /// @notice fee share for liquidity provider
    /// @return the rate share
    function feeShareAmm() external view returns (uint32);
}


// File: @positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAutoMarketMakerCore.sol";
import "./IMatchingEngineCore.sol";
import "./IFee.sol";

interface IMatchingEngineAMM is
    IFee,
    IAutoMarketMakerCore,
    IMatchingEngineCore
{
    struct InitParams {
        IERC20 quoteAsset;
        IERC20 baseAsset;
        uint256 basisPoint;
        uint128 maxFindingWordsIndex;
        uint128 initialPip;
        uint128 pipRange;
        uint32 tickSpace;
        address positionLiquidity;
        address spotHouse;
        address router;
    }

    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    /// @notice init the pair right after cloned
    /// @param params the init params with struct InitParams
    /// @dev save storage the init data
    function initialize(InitParams memory params) external;

    /// @notice get the base and quote amount can claim
    /// @param pip the pip of the order
    /// @param orderId id of order in pip
    /// @param exData the base amount
    /// @param basisPoint the basis point of price
    /// @param fee the fee percent
    /// @param feeBasis the basis fee froe calculate
    /// @return the Exchanged data
    /// @dev calculate the base and quote from order and pip
    function accumulateClaimableAmount(
        uint128 pip,
        uint64 orderId,
        ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (ExchangedData memory);
}


// File: @positionex/matching-engine/contracts/interfaces/IMatchingEngineCore.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IMatchingEngineCore {
    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    /// @notice Emitted when market order filled
    /// @param isBuy side of order
    /// @param amount amount filled
    /// @param toPip fill to pip
    /// @param startPip fill start pip
    /// @param remainingLiquidity remaining liquidity in pip
    /// @param filledIndex number of index filled
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );

    /// @notice Emitted when market order filled
    /// @param orderId side of order
    /// @param pip amount filled
    /// @param size fill to pip
    /// @param isBuy fill start pip
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    /// @notice Emitted limit order cancel
    /// @param size size of order
    /// @param pip of order
    /// @param orderId id of order cancel
    /// @param isBuy fill start pip
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when update max finding word
    /// @param pairManager address of pair
    /// @param newMaxFindingWordsIndex new value
    event UpdateMaxFindingWordsIndex(
        address pairManager,
        uint128 newMaxFindingWordsIndex
    );

    /// @notice Emitted when update max finding word for limit order
    /// @param newMaxWordRangeForLimitOrder new value
    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );

    /// @notice Emitted when update max finding word for market order
    /// @param newMaxWordRangeForMarketOrder new value
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );

    /// @notice Emitted when snap shot reserve
    /// @param pip pip snap shot
    /// @param timestamp time snap shot
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);

    /// @notice Emitted when limit order updated
    /// @param pairManager address of pair
    /// @param orderId id of order
    /// @param pip at order
    /// @param size of order
    event LimitOrderUpdated(
        address pairManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when order fill for swap
    /// @param sender address of trader
    /// @param amount0In amount 0 int
    /// @param amount1In amount 1 in
    /// @param amount0Out amount 0 out
    /// @param amount1Out amount 1 out
    /// @param to swap for address
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /// @notice Update the order when partial fill
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    /// @notice Cancel the limit order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function cancelLimitOrder(
        uint128 pip,
        uint64 orderId
    ) external returns (uint256 remainingSize, uint256 partialFilled);

    /// @notice Open limit order with size and price
    /// @param pip the price of order
    /// @param baseAmountIn amount of base asset
    /// @param isBuy side of the limit order
    /// @param trader the owner of the limit order
    /// @param quoteAmountIn amount of quote asset
    /// @param feePercent fee of the order
    /// @dev Calculate the order in insert to queue
    /// @return orderId id of order in pip
    /// @return baseAmountFilled when can fill market amount has filled
    /// @return quoteAmountFilled when can fill market amount has filled
    /// @return fee when can fill market amount has filled
    function openLimit(
        uint128 pip,
        uint128 baseAmountIn,
        bool isBuy,
        address trader,
        uint256 quoteAmountIn,
        uint16 feePercent
    )
        external
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        );

    /// @notice Open market order with size is base and price
    /// @param size the amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarket(
        uint256 size,
        bool isBuy,
        address trader,
        uint16 feePercent
    ) external returns (uint256 mainSideOut, uint256 flipSideOut, uint256 fee);

    /// @notice Open market order with size is base and price
    /// @param quoteAmount the quote amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader,
        uint16 feePercent
    ) external returns (uint256 mainSideOut, uint256 flipSideOut, uint256 fee);

    /// @notice check at this pip has liquidity
    /// @param pip the price of order
    /// @dev load and check flag of liquidity
    /// @return the bool of has liquidity
    function hasLiquidity(uint128 pip) external view returns (bool);

    /// @notice Get detail pending order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    /// @dev Load pending order and calculate the amount of base and quote asset
    /// @return isFilled the order is filled
    /// @return isBuy the side of the order
    /// @return size the size of order
    /// @return partialFilled the amount partial order is filled
    function getPendingOrderDetail(
        uint128 pip,
        uint64 orderId
    )
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    /// @notice Get amount liquidity pending at current price
    /// @return the amount liquidity pending
    function getLiquidityInCurrentPip() external view returns (uint128);

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view returns (LiquidityOfEachPip[] memory, uint128);

    function calculatingQuoteAmount(
        uint256 quantity,
        uint128 pip
    ) external view returns (uint256);

    /// @notice Get basis point of pair
    /// @return the basis point of pair
    function basisPoint() external view returns (uint256);

    /// @notice Get current price
    /// @return return the current price
    function getCurrentPip() external view returns (uint128);

    /// @notice Calculate the amount of quote asset
    /// @param quoteAmount the quote amount
    /// @param pip the price
    /// @return the base converted
    function quoteToBase(
        uint256 quoteAmount,
        uint128 pip
    ) external view returns (uint256);
}


// File: @positionex/matching-engine/contracts/libraries/amm/Liquidity.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Liquidity {
    struct Info {
        uint128 sqrtMaxPip;
        uint128 sqrtMinPip;
        uint128 quoteReal;
        uint128 baseReal;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        uint128 sqrtK;
    }

    /// @notice Define the new pip range when the first time add liquidity
    /// @param self the liquidity info
    /// @param sqrtMaxPip the max pip
    /// @param sqrtMinPip the min pip
    /// @param indexedPipRange the index of liquidity info
    function initNewPipRange(
        Liquidity.Info storage self,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip,
        uint32 indexedPipRange
    ) internal {
        self.sqrtMaxPip = sqrtMaxPip;
        self.sqrtMinPip = sqrtMinPip;
        self.indexedPipRange = indexedPipRange;
    }

    /// @notice update the liquidity info when add liquidity
    /// @param self the liquidity info
    /// @param updater of struct Liquidity.Info, this is new value of liquidity info
    function updateRangeLiquidity(
        Liquidity.Info storage self,
        Liquidity.Info memory updater
    ) internal {
        if (self.sqrtK == 0) {
            self.sqrtMaxPip = updater.sqrtMaxPip;
            self.sqrtMinPip = updater.sqrtMinPip;
            self.indexedPipRange = updater.indexedPipRange;
        }
        self.quoteReal = updater.quoteReal;
        self.baseReal = updater.baseReal;
        self.sqrtK = updater.sqrtK;
    }

    /// @notice growth fee base and quote
    /// @param self the liquidity info
    /// @param feeGrowthBase the growth of base
    /// @param feeGrowthQuote the growth of base
    function updateFeeGrowth(
        Liquidity.Info storage self,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }

    /// @notice update the liquidity info when after trade and save to storage
    /// @param self the liquidity info
    /// @param baseReserve the new value of baseReserve
    /// @param quoteReserve the new value of quoteReserve
    /// @param feeGrowth new growth value increase
    /// @param isBuy the side of trade
    function updateAMMReserve(
        Liquidity.Info storage self,
        uint128 quoteReserve,
        uint128 baseReserve,
        uint256 feeGrowth,
        bool isBuy
    ) internal {
        self.quoteReal = quoteReserve;
        self.baseReal = baseReserve;

        if (isBuy) {
            self.feeGrowthBase += feeGrowth;
        } else {
            self.feeGrowthQuote += feeGrowth;
        }
    }
}


// File: @positionex/matching-engine/contracts/libraries/amm/LiquidityMath.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../helper/FixedPoint128.sol";

/// @title All formulas used in the AMM
library LiquidityMath {
    /// @notice calculate base real from virtual
    /// @param sqrtMaxPip sqrt the max price
    /// @param xVirtual the base virtual
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base real
    function calculateBaseReal(
        uint128 sqrtMaxPip,
        uint128 xVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMaxPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtMaxPip) * uint256(xVirtual)) /
                    (uint256(sqrtMaxPip) - uint256(sqrtCurrentPrice))
            );
    }

    /// @notice calculate quote real from virtual
    /// @param sqrtMinPip sqrt the max price
    /// @param yVirtual the quote virtual
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote real
    function calculateQuoteReal(
        uint128 sqrtMinPip,
        uint128 yVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMinPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtCurrentPrice) * uint256(yVirtual)) /
                    (uint256(sqrtCurrentPrice) - uint256(sqrtMinPip))
            );
    }

    /// @title These functions below are used to calculate the amount asset when SELL

    /// @notice calculate base amount with target price when sell
    /// @param sqrtPriceTarget sqrt the target price
    /// @param quoteReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base amount
    function calculateBaseWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (FixedPoint128.BUFFER *
                    (uint256(quoteReal) *
                        (uint256(sqrtCurrentPrice) -
                            uint256(sqrtPriceTarget)))) /
                    (uint256(sqrtPriceTarget) * uint256(sqrtCurrentPrice) ** 2)
            );
    }

    /// @notice calculate quote amount with target price when sell
    /// @param sqrtPriceTarget sqrt the target price
    /// @param quoteReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote amount
    function calculateQuoteWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(quoteReal) *
                    (uint256(sqrtCurrentPrice) - uint256(sqrtPriceTarget))) /
                    uint256(sqrtCurrentPrice)
            );
    }

    /// @notice calculate base amount with target price when buy
    /// @param sqrtPriceTarget sqrt the target price
    /// @param baseReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base amount
    function calculateBaseWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    uint256(sqrtPriceTarget)
            );
    }

    /// @notice calculate quote amount with target price when buy
    /// @param sqrtPriceTarget sqrt the target price
    /// @param baseReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote amount
    function calculateQuoteWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    uint256(sqrtCurrentPrice) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    FixedPoint128.BUFFER
            );
    }

    /// @notice calculate index pip range
    /// @param pip the pip want to calculate
    /// @param pipRange the range of pair
    /// @return the index pip range
    function calculateIndexPipRange(
        uint128 pip,
        uint128 pipRange
    ) internal pure returns (uint256) {
        return uint256(pip / pipRange);
    }

    /// @notice calculate max in min pip in index
    /// @param indexedPipRange the index pip range
    /// @param pipRange the range of pair
    /// @return pipMin the min pip in index
    /// @return pipMax the max pip in index
    function calculatePipRange(
        uint32 indexedPipRange,
        uint128 pipRange
    ) internal pure returns (uint128 pipMin, uint128 pipMax) {
        pipMin = indexedPipRange == 0 ? 1 : indexedPipRange * pipRange;
        pipMax = pipMin + pipRange - 1;
    }

    /// @notice calculate quote and quote amount with no target price when sell
    /// @param sqrtK the sqrt k- mean liquidity
    /// @param amountReal amount real
    /// @param amount amount
    /// @return the amount base or quote
    function calculateBaseBuyAndQuoteSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(amountReal) ** 2) /
                    (uint256(sqrtK) ** 2 + amount * uint256(amountReal))
            );
    }

    /// @notice calculate quote and quote amount with no target price when buy
    /// @param sqrtK the sqrt k- mean liquidity
    /// @param amountReal amount real
    /// @param amount amount
    /// @return the amount base or quote
    function calculateQuoteBuyAndBaseSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(sqrtK) ** 2) /
                    (uint256(amountReal) *
                        (uint256(amountReal) - uint256(amount)))
            );
    }

    /// @notice calculate K ( liquidity) with quote real
    /// @param quoteReal the quote real
    /// @param sqrtPriceMax sqrt of price max
    function calculateKWithQuote(
        uint128 quoteReal,
        uint128 sqrtPriceMax
    ) internal pure returns (uint256) {
        return
            (uint256(quoteReal) ** 2 / uint256(sqrtPriceMax)) *
            (FixedPoint128.BUFFER / uint256(sqrtPriceMax));
    }

    /// @notice calculate K ( liquidity) with base real
    /// @param baseReal the quote real
    /// @param sqrtPriceMin sqrt of price max
    function calculateKWithBase(
        uint128 baseReal,
        uint128 sqrtPriceMin
    ) internal pure returns (uint256) {
        return
            (uint256(baseReal) ** 2 / FixedPoint128.HALF_BUFFER) *
            (uint256(sqrtPriceMin) ** 2 / FixedPoint128.HALF_BUFFER);
    }

    /// @notice calculate K ( liquidity) with base real and quote ral
    /// @param baseReal the quote real
    /// @param baseReal the base real
    function calculateKWithBaseAndQuote(
        uint128 quoteReal,
        uint128 baseReal
    ) internal pure returns (uint256) {
        return uint256(quoteReal) * uint256(baseReal);
    }

    /// @notice calculate the liquidity
    /// @param amountReal the amount real
    /// @param sqrtPrice sqrt of price
    /// @param isBase true if base, false if quote
    /// @return the liquidity
    function calculateLiquidity(
        uint128 amountReal,
        uint128 sqrtPrice,
        bool isBase
    ) internal pure returns (uint256) {
        if (isBase) {
            return uint256(amountReal) * uint256(sqrtPrice);
        } else {
            return uint256(amountReal) / uint256(sqrtPrice);
        }
    }

    /// @notice calculate base by the liquidity
    /// @param liquidity the liquidity
    /// @param sqrtPriceMax sqrt of price max
    /// @param sqrtPrice  sqrt of current price
    /// @return the base amount
    function calculateBaseByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMax,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (FixedPoint128.HALF_BUFFER *
                    uint256(liquidity) *
                    (uint256(sqrtPriceMax) - uint256(sqrtPrice))) /
                    (uint256(sqrtPrice) * uint256(sqrtPriceMax))
            );
    }

    /// @notice calculate quote by the liquidity
    /// @param liquidity the liquidity
    /// @param sqrtPriceMin sqrt of price min
    /// @param sqrtPrice  sqrt of current price
    /// @return the quote amount
    function calculateQuoteByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMin,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) *
                    (uint256(sqrtPrice) - uint256(sqrtPriceMin))) /
                    FixedPoint128.HALF_BUFFER
            );
    }

    /// @notice calculate base real by the liquidity
    /// @param liquidity the liquidity
    /// @param totalLiquidity the total liquidity of liquidity info
    /// @param totalBaseReal total base real of liquidity
    /// @return the base real
    function calculateBaseRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalBaseReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalBaseReal) / uint256(totalLiquidity)
            );
    }

    /// @notice calculate quote real by the liquidity
    /// @param liquidity the liquidity
    /// @param totalLiquidity the total liquidity of liquidity info
    /// @param totalQuoteReal total quote real of liquidity
    /// @return the quote real
    function calculateQuoteRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalQuoteReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalQuoteReal) / uint256(totalLiquidity)
            );
    }

    /// @notice calculate quote virtual from base virtual
    /// @param baseVirtualAmount the base virtual amount
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtMaxPip sqrt of max pip
    /// @param sqrtMinPip sqrt of min pip
    /// @return quoteVirtualAmount the quote virtual amount
    function calculateQuoteVirtualAmountFromBaseVirtualAmount(
        uint128 baseVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 quoteVirtualAmount) {
        return
            (baseVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            (sqrtMaxPip * sqrtCurrentPrice);
    }

    /// @notice calculate base virtual from quote virtual
    /// @param quoteVirtualAmount the quote virtual amount
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtMaxPip sqrt of max pip
    /// @param sqrtMinPip sqrt of min pip
    /// @return  baseVirtualAmount the base virtual amount
    function calculateBaseVirtualAmountFromQuoteVirtualAmount(
        uint128 quoteVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 baseVirtualAmount) {
        return
            (quoteVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            ((sqrtCurrentPrice - sqrtMinPip) * sqrtCurrentPrice * sqrtMaxPip);
    }
}


// File: @positionex/matching-engine/contracts/libraries/helper/FixedPoint128.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
    uint256 internal constant BUFFER = 10 ** 24;
    uint256 internal constant Q_POW18 = 10 ** 18;
    uint256 internal constant HALF_BUFFER = 10 ** 12;
    uint32 internal constant BASIC_POINT_FEE = 10_000;
    uint8 internal constant MAX_FIND_INDEX_RANGE = 4;
}


// File: @positionex/matching-engine/contracts/libraries/helper/Math.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Math {
    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

    /// @notice Get minimum of two numbers.
    /// @return z the number with the minimum value.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }
}


// File: contracts/interfaces/ILiquidityManager.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/liquidity/Liquidity.sol";

interface ILiquidityManager {
    enum ModifyType {
        INCREASE,
        DECREASE
    }

    struct AddLiquidityParams {
        IMatchingEngineAMM pool;
        uint128 amountVirtual;
        uint32 indexedPipRange;
        bool isBase;
    }

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    struct LiquidityDetail {
        uint128 baseVirtual;
        uint128 quoteVirtual;
        uint128 liquidity;
        uint128 power;
        uint256 indexedPipRange;
        uint128 feeBasePending;
        uint128 feeQuotePending;
        IMatchingEngineAMM pool;
    }

    /// @dev get all data of nft
    /// @param tokens array of tokens
    /// @return list array of struct LiquidityDetail
    function getAllDataDetailTokens(uint256[] memory tokens)
        external
        view
        returns (LiquidityDetail[] memory);

    /// @notice get data of tokens
    /// @param tokenId the id of token
    /// @return liquidity the value liquidity
    /// @return indexedPipRange the index pip range of token
    /// @return feeGrowthBase checkpoint of fee base
    /// @return feeGrowthQuote checkpoint of fee quote
    /// @return pool the pool liquidity provide
    function concentratedLiquidity(uint256 tokenId)
        external
        view
        returns (
            uint128 liquidity,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            IMatchingEngineAMM pool
        );

    /// @dev get data of nft
    /// @notice provide liquidity for pool
    /// @param params struct of AddLiquidityParams
    function addLiquidity(AddLiquidityParams calldata params) external payable;

    /// @dev get data of nft
    /// @notice provide liquidity for pool with recipient nft id
    /// @param params struct of AddLiquidityParams
    /// @param recipient address to receive nft
    function addLiquidityWithRecipient(
        AddLiquidityParams calldata params,
        address recipient
    ) external payable;

    /// @dev remove liquidity
    /// @notice remove liquidity of token id and transfer asset
    /// @param nftTokenId id of token
    function removeLiquidity(uint256 nftTokenId) external;

    /// @dev remove liquidity
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param amountModify amount increase
    /// @param isBase amount is base or quote
    function increaseLiquidity(
        uint256 nftTokenId,
        uint128 amountModify,
        bool isBase
    ) external payable;

    /// @dev decrease liquidity and transfer asset
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param liquidity amount decrease
    function decreaseLiquidity(uint256 nftTokenId, uint128 liquidity) external;

    /// @dev shiftRange to other index of range
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param targetIndex target index shift to
    /// @param amountNeeded amount need more
    /// @param isBase amount need more is base or quote
    function shiftRange(
        uint256 nftTokenId,
        uint32 targetIndex,
        uint128 amountNeeded,
        bool isBase
    ) external payable;

    /// @dev collect fee reward and transfer asset
    /// @notice collect fee reward
    /// @param nftTokenId id of token
    function collectFee(uint256 nftTokenId) external;

    /// @notice get liquidity detail of token id
    /// @param baseVirtual base amount with impairment loss
    /// @param quoteVirtual quote amount with impairment loss
    /// @param liquidity the amount of liquidity
    /// @param indexedPipRange index pip range provide liquidity
    /// @param feeBasePending amount fee base pending to collect
    /// @param feeQuotePending amount fee quote pending to collect
    /// @param pool provide liquidity
    function liquidity(uint256 nftTokenId)
        external
        view
        returns (
            uint128 baseVirtual,
            uint128 quoteVirtual,
            uint128 liquidity,
            uint128 power,
            uint256 indexedPipRange,
            uint128 feeBasePending,
            uint128 feeQuotePending,
            IMatchingEngineAMM pool
        );

    //------------------------------------------------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------------------------------------------------

    event LiquidityAdded(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseAdded,
        uint256 amountQuoteAdded,
        uint64 indexedPipRange,
        uint256 addedLiquidity
    );

    event LiquidityRemoved(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 indexedPipRange,
        uint128 removedLiquidity
    );

    event LiquidityModified(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseModified,
        uint256 amountQuoteModified,
        // 0: increase
        // 1: decrease
        ModifyType modifyType,
        uint64 indexedPipRange,
        uint128 modifiedLiquidity
    );

    event LiquidityShiftRange(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint64 oldIndexedPipRange,
        uint128 liquidityRemoved,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 newIndexedPipRange,
        uint128 newLiquidity,
        uint256 amountBaseAdded,
        uint256 amountQuoteAded
    );
}


// File: contracts/interfaces/ILiquidityManagerNFT.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface ILiquidityManagerNFT {
    /// @notice get the last token id
    /// @return the last token id
    function tokenID() external view returns (uint256);
}


// File: contracts/interfaces/IPositionNondisperseLiquidity.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

import "./ILiquidityManager.sol";
import "./ILiquidityManagerNFT.sol";

interface IPositionNondisperseLiquidity is
    ILiquidityManager,
    ILiquidityManagerNFT,
    IERC721Upgradeable
{}


// File: contracts/interfaces/IPositionStakingDexManager.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;


interface IPositionStakingDexManager {
    function stakeAfterMigrate(uint256 nftId, address user ) external;
}


// File: contracts/interfaces/ISpotFactory.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface ISpotFactory {
    event PairManagerInitialized(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        address owner,
        address pairManager,
        uint256 pipRange,
        uint256 tickSpace
    );

    event StakingForPairAdded(
        address pairManager,
        address stakingAddress,
        address ownerOfPair
    );

    struct Pair {
        address BaseAsset;
        address QuoteAsset;
    }

    /// @notice create new pair for dex
    /// @param quoteAsset address of quote asset
    /// @param baseAsset address of base asset
    /// @param basisPoint the basis point for pip and price
    /// @param maxFindingWordsIndex the max word can finding
    /// @param initialPip the pip start of the pair
    /// @param pipRange the range of liquidity index
    /// @param tickSpace tick space for generate orderbook
    function createPairManager(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint128 pipRange,
        uint32 tickSpace
    ) external;

    /// @notice get pair manager address
    /// @param quoteAsset the address of quote asset
    /// @param baseAsset the address of base asset
    /// @return pairManager the address of pair manager
    function getPairManager(address quoteAsset, address baseAsset)
        external
        view
        returns (address pairManager);

    /// @notice get the quote asset and base asset
    /// @param pairManager the address of pair
    /// @return struct of quote and base
    function getQuoteAndBase(address pairManager)
        external
        view
        returns (Pair memory);

    /// @notice check pair manager is exist
    /// @param pairManager the address of pair
    /// @return true if exist, false if not exist
    function isPairManagerExist(address pairManager)
        external
        view
        returns (bool);

    /// @notice check pair and assets is supported with random two token
    /// @param tokenA the first token
    /// @param tokenB the second token
    /// @return baseToken the address of base token
    /// @return quoteToken the address of quote token
    /// @return pairManager the address of pair
    function getPairManagerSupported(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );

    /// @notice get staking manager of pair
    /// @param owner the owner of pair
    /// @param pair the address of pair
    /// @return the address of contract staking manager
    function stakingManagerOfPair(address owner, address pair)
        external
        view
        returns (address);

    /// @notice get owner of pair
    /// @param pair the address of pair
    /// @return address owner of pair
    function ownerPairManager(address pair) external view returns (address);

    /// @notice fee share for liquidity provider
    /// @return the rate share
    function feeShareAmm() external view returns (uint32);
}


// File: contracts/interfaces/IUniswapV2Factory.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.9;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


// File: contracts/interfaces/IUniswapV2Pair.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.9;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


// File: contracts/interfaces/IUniswapV2Router.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


// File: contracts/interfaces/IWBNB.sol
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}


// File: contracts/libraries/helper/Convert.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Convert {
    //    function Uint256ToUint128(uint256 x) internal pure returns (uint128) {
    //        return uint128(x);
    //    }
    //
    //    function Uint256ToUint64(uint256 x) internal pure returns (uint64) {
    //        return uint64(x);
    //    }
    //
    //    function Uint256ToUint32(uint256 x) internal pure returns (uint32) {
    //        return uint32(x);
    //    }
    //
    //    function toI256(uint256 x) internal pure returns (int256) {
    //        return int256(x);
    //    }
    //
    //    function toI128(uint256 x) internal pure returns (int128) {
    //        return int128(int256(x));
    //    }
    //
    //    function abs(int256 x) internal pure returns (uint256) {
    //        return uint256(x >= 0 ? x : -x);
    //    }
    //
    //    function abs256(int128 x) internal pure returns (uint256) {
    //        return uint256(uint128(x >= 0 ? x : -x));
    //    }
    //
    //    function toU128(uint256 x) internal pure returns (uint128) {
    //        return uint128(x);
    //    }
    //
    //    function Uint256ToUint40(uint256 x) internal returns (uint40) {
    //        return uint40(x);
    //    }
}


// File: contracts/libraries/helper/LiquidityHelper.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./Convert.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/amm/LiquidityMath.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Math.sol";

library LiquidityHelper {
    /// @notice calculate quote virtual from base real
    /// @param baseReal the amount base real
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtPriceMin the sqrt of min price
    /// @param sqrtBasicPoint the sqrt of basisPoint
    function calculateQuoteVirtualFromBaseReal(
        uint128 baseReal,
        uint128 sqrtCurrentPrice,
        uint128 sqrtPriceMin,
        uint256 sqrtBasicPoint
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    uint256(sqrtCurrentPrice / sqrtBasicPoint) *
                    (uint256(sqrtCurrentPrice / sqrtBasicPoint) -
                        uint256(sqrtPriceMin / sqrtBasicPoint))) / 10**18
            );
    }

    /// @notice calculate base virtual from quote real
    /// @param quoteReal the amount quote real
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtPriceMax the sqrt of max price
    function calculateBaseVirtualFromQuoteReal(
        uint128 quoteReal,
        uint128 sqrtCurrentPrice,
        uint128 sqrtPriceMax
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(quoteReal) *
                    10**18 *
                    (uint256(sqrtPriceMax) - uint256(sqrtCurrentPrice))) /
                    (uint256(sqrtCurrentPrice**2 * sqrtPriceMax))
            );
    }
}


// File: contracts/libraries/helper/TransferHelper.sol
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    /// @notice Transfers tokens from the targeted address to the given destination
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        token.transferFrom(from, to, value);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }

    /// @notice check approve with token and spender
    /// @param token need check approve
    /// @param spender need grant permit to transfer token
    /// @return bool type after check
    function isApprove(address token, address spender)
        internal
        view
        returns (bool)
    {
        return
            IERC20(token).allowance(address(this), spender) > 0 ? true : false;
    }

    /// @notice approve token with spender
    /// @param token need  approve
    /// @param spender need grant permit to transfer token
    function approve(address token, address spender) internal {
        IERC20(token).approve(spender, type(uint256).max);
    }
}


// File: contracts/libraries/liquidity/Liquidity.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";

library UserLiquidity {
    struct Data {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        IMatchingEngineAMM pool;
    }

    struct CollectFeeData {
        uint128 feeBaseAmount;
        uint128 feeQuoteAmount;
        uint256 newFeeGrowthBase;
        uint256 newFeeGrowthQuote;
    }

    /// @notice update the liquidity of user
    /// @param liquidity the liquidity of user
    /// @param indexedPipRange the index of liquidity info
    /// @param feeGrowthBase the growth of base
    /// @param feeGrowthQuote the growth of quote
    function updateLiquidity(
        Data storage self,
        uint128 liquidity,
        uint32 indexedPipRange,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.liquidity = liquidity;
        self.indexedPipRange = indexedPipRange;
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }
}


// File: contracts/migration/KillerPosition.sol
/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/amm/LiquidityMath.sol";

import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IPositionNondisperseLiquidity.sol";
import "../interfaces/ISpotFactory.sol";
import "../interfaces/IWBNB.sol";
import "../libraries/helper/LiquidityHelper.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/ISpotFactory.sol";
import {TransferHelper} from "../libraries/helper/TransferHelper.sol";
import "../interfaces/IPositionStakingDexManager.sol";

contract KillerPosition is ReentrancyGuard, Ownable {
    using Address for address payable;

    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Factory public uniswapV2Factory;
    IPositionNondisperseLiquidity public positionLiquidity;
    ISpotFactory public spotFactory;
    IWBNB public WBNB;

    IPositionStakingDexManager public stakingDexManager;

    receive() external payable {
        //        assert(msg.sender == address(uniswapRouter));
        // only accept BNB via fallback from the WBNB contract
    }

    event PositionLiquidityMigrated(
        address user,
        uint256 nftId,
        uint256 liquidityMigrated,
        address lpAddress,
        address pairManager
    );

    constructor(
        IUniswapV2Router02 _uniswapRouter,
        IPositionNondisperseLiquidity _positionLiquidity,
        ISpotFactory _spotFactory,
        IWBNB _WBNB
    ) {
        uniswapRouter = _uniswapRouter;
        positionLiquidity = _positionLiquidity;
        spotFactory = _spotFactory;
        WBNB = _WBNB;
    }

    struct State {
        uint128 currentPip;
        uint32 currentIndexedPipRange;
        address baseToken;
        address quoteToken;
        address pairManager;
        uint256 amount0;
        uint256 amount1;
        uint256 balance0;
        uint256 balance1;
    }

    function approveStaking() public {
        positionLiquidity.setApprovalForAll(address(stakingDexManager), true);
    }

    // TODO remove when testing done
    function updateUniswapRouter(IUniswapV2Router02 _new) external onlyOwner {
        uniswapRouter = _new;
    }

    function updateStakingDexManager(IPositionStakingDexManager _stakingDexManager) external onlyOwner {
        stakingDexManager = _stakingDexManager;
    }


    function updatePositionLiquidity(
        IPositionNondisperseLiquidity _positionLiquidity
    ) external onlyOwner {
        positionLiquidity = _positionLiquidity;
    }

    function updateSpotFactory(ISpotFactory _spotFactory) external onlyOwner {
        spotFactory = _spotFactory;
    }

    function updateWBNB(IWBNB _WBNB) external onlyOwner {
        WBNB = _WBNB;
    }

    function updateUniswapV2Factory(IUniswapV2Factory _uniswapV2Factory)
        external
        onlyOwner
    {
        uniswapV2Factory = _uniswapV2Factory;
    }

    function isToken0Base(IUniswapV2Pair pair) public view returns (bool) {
        (address baseToken, , ) = spotFactory.getPairManagerSupported(
            pair.token0(),
            pair.token1()
        );

        return baseToken == pair.token0();
    }

    function getLpAddress(address matching) public view returns (address) {
        ISpotFactory.Pair memory pair = spotFactory.getQuoteAndBase(matching);
        return uniswapV2Factory.getPair(pair.QuoteAsset, pair.BaseAsset);
    }

    function stake(uint256 ndtId, address user) internal {
        stakingDexManager.stakeAfterMigrate(ndtId, user);
    }

    function migratePosition(IUniswapV2Pair pair, uint256 liquidity)
        public
        nonReentrant
    {
        State memory state;
        address user = _msgSender();

        address token0 = pair.token0();
        address token1 = pair.token1();

        pair.transferFrom(user, address(this), liquidity);
        (state.baseToken, state.quoteToken, state.pairManager) = spotFactory
            .getPairManagerSupported(token0, token1);

        _approve(address(pair), address(uniswapRouter));
        _approve(token0, address(positionLiquidity));
        _approve(token1, address(positionLiquidity));

        state.balance0 = _balanceOf(token0, address(this));
        state.balance1 = _balanceOf(token1, address(this));

        require(state.pairManager != address(0x00), "!0x0");
        if (token0 == address(WBNB) || token1 == address(WBNB)) {
            uniswapRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
                token0 == address(WBNB) ? token1 : token0,
                liquidity,
                0,
                0,
                address(this),
                9999999999
            );
        } else {
            uniswapRouter.removeLiquidity(
                token0,
                token1,
                liquidity,
                0,
                0,
                address(this),
                9999999999
            );
        }

        state.amount0 = _balanceOf(token0, address(this)) - state.balance0;
        state.amount1 = _balanceOf(token1, address(this)) - state.balance1;

        state.balance0 = _balanceOf(token0, address(this));
        state.balance1 = _balanceOf(token1, address(this));

        bool _isToken0Base = state.baseToken == pair.token0();

        state.currentIndexedPipRange = uint32(
            IMatchingEngineAMM(state.pairManager).currentIndexedPipRange()
        );
        state.currentPip = IMatchingEngineAMM(state.pairManager)
            .getCurrentPip();

        (uint128 minPip, uint128 maxPip) = LiquidityMath.calculatePipRange(
            state.currentIndexedPipRange,
            IMatchingEngineAMM(state.pairManager).pipRange()
        );

        if (minPip == state.currentPip) {
            uint256 _value;

            if (
                (_isToken0Base && token0 == address(WBNB)) ||
                (!_isToken0Base && token0 == address(WBNB))
            ) {
                _value = state.amount0;
            }

            if (
                (!_isToken0Base && token1 == address(WBNB)) ||
                (_isToken0Base && token1 == address(WBNB))
            ) {
                _value = state.amount1;
            }
            /// add only base
            positionLiquidity.addLiquidityWithRecipient{value: _value}(
                ILiquidityManager.AddLiquidityParams({
                    pool: IMatchingEngineAMM(state.pairManager),
                    amountVirtual: _isToken0Base
                        ? uint128(state.amount0)
                        : uint128(state.amount1),
                    indexedPipRange: state.currentIndexedPipRange,
                    isBase: true
                }),
                address(this)
            );
        } else if (maxPip == state.currentPip) {
            uint256 _value;
            if (
                (_isToken0Base && token0 == address(WBNB)) ||
                (!_isToken0Base && token0 == address(WBNB))
            ) {
                _value = state.amount0;
            }

            if (
                (!_isToken0Base && token1 == address(WBNB)) ||
                (_isToken0Base && token1 == address(WBNB))
            ) {
                _value = state.amount1;
            }

            /// add only quote
            positionLiquidity.addLiquidityWithRecipient{value: _value}(
                ILiquidityManager.AddLiquidityParams({
                    pool: IMatchingEngineAMM(state.pairManager),
                    amountVirtual: _isToken0Base
                        ? uint128(state.amount1)
                        : uint128(state.amount0),
                    indexedPipRange: state.currentIndexedPipRange,
                    isBase: false
                }),
                address(this)
            );
        } else {
            uint128 amountBase;
            uint128 amountQuote;
            state.currentPip = sqrt(uint256(state.currentPip) * 10**18);
            maxPip = sqrt(uint256(maxPip) * 10**18);
            minPip = sqrt(uint256(minPip) * 10**18);
            if (_isToken0Base) {
                (amountBase, amountQuote) = _estimate(
                    uint128(state.amount0),
                    true,
                    state.currentPip,
                    maxPip,
                    minPip,
                    state.pairManager
                );

                if (amountQuote <= state.amount1) {
                    try
                        positionLiquidity.addLiquidityWithRecipient{
                            value: _calculateValue(
                                token0,
                                token1,
                                amountBase,
                                amountQuote,
                                _isToken0Base
                            )
                        }(
                            ILiquidityManager.AddLiquidityParams({
                                pool: IMatchingEngineAMM(state.pairManager),
                                amountVirtual: uint128(state.amount0),
                                indexedPipRange: state.currentIndexedPipRange,
                                isBase: true
                            }),
                            address(this)
                        )
                    {} catch Error(string memory reason) {
                        if (_isCatch(reason)) {
                            amountQuote = (amountQuote * 9990) / 10_000;
                            positionLiquidity.addLiquidityWithRecipient{
                                value: _calculateValue(
                                    token0,
                                    token1,
                                    amountBase,
                                    amountQuote,
                                    _isToken0Base
                                )
                            }(
                                ILiquidityManager.AddLiquidityParams({
                                    pool: IMatchingEngineAMM(state.pairManager),
                                    amountVirtual: uint128(amountQuote),
                                    indexedPipRange: state
                                        .currentIndexedPipRange,
                                    isBase: false
                                }),
                                address(this)
                            );
                        } else revert(reason);
                    }
                } else {
                    (amountBase, amountQuote) = _estimate(
                        uint128(state.amount1),
                        false,
                        state.currentPip,
                        maxPip,
                        minPip,
                        state.pairManager
                    );

                    amountBase = (amountBase * 9990) / 10_000;
                    try
                        positionLiquidity.addLiquidityWithRecipient{
                            value: _calculateValue(
                                token0,
                                token1,
                                amountBase,
                                amountQuote,
                                _isToken0Base
                            )
                        }(
                            ILiquidityManager.AddLiquidityParams({
                                pool: IMatchingEngineAMM(state.pairManager),
                                amountVirtual: amountBase,
                                indexedPipRange: state.currentIndexedPipRange,
                                isBase: true
                            }),
                            address(this)
                        )
                    {} catch Error(string memory reason) {
                        if (_isCatch(reason)) {
                            amountQuote = (amountQuote * 9990) / 10_000;
                            positionLiquidity.addLiquidityWithRecipient{
                                value: _calculateValue(
                                    token0,
                                    token1,
                                    amountBase,
                                    amountQuote,
                                    _isToken0Base
                                )
                            }(
                                ILiquidityManager.AddLiquidityParams({
                                    pool: IMatchingEngineAMM(state.pairManager),
                                    amountVirtual: uint128(amountQuote),
                                    indexedPipRange: state
                                        .currentIndexedPipRange,
                                    isBase: false
                                }),
                                address(this)
                            );
                        } else revert(reason);
                    }
                }
            } else {
                (amountBase, amountQuote) = _estimate(
                    uint128(state.amount1),
                    true,
                    state.currentPip,
                    maxPip,
                    minPip,
                    state.pairManager
                );

                if (amountQuote <= state.amount0) {
                    try
                        positionLiquidity.addLiquidityWithRecipient{
                            value: _calculateValue(
                                token0,
                                token1,
                                amountBase,
                                amountQuote,
                                _isToken0Base
                            )
                        }(
                            ILiquidityManager.AddLiquidityParams({
                                pool: IMatchingEngineAMM(state.pairManager),
                                amountVirtual: uint128(state.amount1),
                                indexedPipRange: state.currentIndexedPipRange,
                                isBase: true
                            }),
                            address(this)
                        )
                    {} catch Error(string memory reason) {
                        if (_isCatch(reason)) {
                            amountQuote = (amountQuote * 9990) / 10_000;
                            positionLiquidity.addLiquidityWithRecipient{
                                value: _calculateValue(
                                    token0,
                                    token1,
                                    amountBase,
                                    amountQuote,
                                    _isToken0Base
                                )
                            }(
                                ILiquidityManager.AddLiquidityParams({
                                    pool: IMatchingEngineAMM(state.pairManager),
                                    amountVirtual: uint128(amountQuote),
                                    indexedPipRange: state
                                        .currentIndexedPipRange,
                                    isBase: false
                                }),
                                address(this)
                            );
                        } else revert(reason);
                    }
                } else {
                    (amountBase, amountQuote) = _estimate(
                        uint128(state.amount0),
                        false,
                        state.currentPip,
                        maxPip,
                        minPip,
                        state.pairManager
                    );

                    amountBase = (amountBase * 9990) / 10_000;

                    try
                        positionLiquidity.addLiquidityWithRecipient{
                            value: _calculateValue(
                                token0,
                                token1,
                                amountBase,
                                amountQuote,
                                _isToken0Base
                            )
                        }(
                            ILiquidityManager.AddLiquidityParams({
                                pool: IMatchingEngineAMM(state.pairManager),
                                amountVirtual: amountBase,
                                indexedPipRange: state.currentIndexedPipRange,
                                isBase: true
                            }),
                            address(this)
                        )
                    {} catch Error(string memory reason) {
                        if (_isCatch(reason)) {
                            amountQuote = (amountQuote * 9990) / 10_000;
                            positionLiquidity.addLiquidityWithRecipient{
                                value: _calculateValue(
                                    token0,
                                    token1,
                                    amountBase,
                                    amountQuote,
                                    _isToken0Base
                                )
                            }(
                                ILiquidityManager.AddLiquidityParams({
                                    pool: IMatchingEngineAMM(state.pairManager),
                                    amountVirtual: uint128(amountQuote),
                                    indexedPipRange: state
                                        .currentIndexedPipRange,
                                    isBase: false
                                }),
                                address(this)
                            );
                        } else revert(reason);
                    }
                }
            }
        }

        _getBack(
            token0,
            uint128(
                state.amount0 -
                    (state.balance0 - _balanceOf(token0, address(this)))
            ),
            user
        );
        _getBack(
            token1,
            uint128(
                state.amount1 -
                    (state.balance1 - _balanceOf(token1, address(this)))
            ),
            user
        );

        stake(positionLiquidity.tokenID(), user);


        emit PositionLiquidityMigrated(
            user,
            positionLiquidity.tokenID(),
            liquidity,
            address(pair),
            state.pairManager
        );
    }

    function _isCatch(string memory reason) internal pure returns (bool) {
        return
            (keccak256(abi.encodePacked((reason))) ==
                keccak256(
                    abi.encodePacked(("ERC20: transfer amount exceeds balance"))
                )) ||
            (keccak256(abi.encodePacked((reason))) ==
                keccak256(abi.encodePacked(("LQ_07"))));
    }

    function sqrt(uint256 number) internal pure returns (uint128) {
        return uint128(Math.sqrt(number));
    }

    function _approve(address token, address spender) internal {
        if (!TransferHelper.isApprove(token, spender)) {
            TransferHelper.approve(token, spender);
        }
    }

    function _calculateValue(
        address _token0,
        address _token1,
        uint128 _amountBase,
        uint128 _amountQuote,
        bool _isToken0Base
    ) internal view returns (uint256 value) {
        if (
            (_token0 == address(WBNB) && _isToken0Base) ||
            (_token1 == address(WBNB) && !_isToken0Base)
        ) {
            value = _amountBase;
        }

        if (
            (_token0 == address(WBNB) && !_isToken0Base) ||
            (_token1 == address(WBNB) && _isToken0Base)
        ) {
            value = _amountQuote;
        }
    }

    function _estimate(
        uint128 amountVirtual,
        bool isBase,
        uint128 currentPip,
        uint128 maxPip,
        uint128 minPip,
        address pair
    ) internal view returns (uint128 amountBase, uint128 amountQuote) {
        if (isBase) {
            amountBase = amountVirtual;
            amountQuote = LiquidityHelper.calculateQuoteVirtualFromBaseReal(
                LiquidityMath.calculateBaseReal(
                    maxPip,
                    amountVirtual,
                    currentPip
                ),
                currentPip,
                minPip,
                uint128(Math.sqrt(IMatchingEngineAMM(pair).basisPoint()))
            );
        } else {
            amountQuote = amountVirtual;
            amountBase =
                LiquidityHelper.calculateBaseVirtualFromQuoteReal(
                    LiquidityMath.calculateQuoteReal(
                        minPip,
                        amountVirtual,
                        currentPip
                    ),
                    currentPip,
                    maxPip
                ) *
                uint128(IMatchingEngineAMM(pair).basisPoint());
        }
    }

    function _msgSender() internal view override(Context) returns (address) {
        return msg.sender;
    }

    function _getBack(
        address token,
        uint128 amount,
        address user
    ) internal {
        if (amount == 0) return;
        if (token == address(WBNB)) {
            payable(user).sendValue(amount);
        } else {
            IERC20(token).transfer(user, amount);
        }
    }

    function _balanceOf(address token, address instance)
        internal
        view
        returns (uint256)
    {
        if (token == address(WBNB)) {
            return instance.balance;
        }
        return IERC20(token).balanceOf(instance);
    }
}

