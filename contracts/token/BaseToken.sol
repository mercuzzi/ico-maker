pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "eth-token-recover/contracts/TokenRecover.sol";
import "../access/roles/OperatorRole.sol";

/**
 * @title BaseToken
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Implementation of a BaseToken
 */
contract BaseToken is ERC20Detailed, ERC20Capped, ERC20Burnable, ERC1363, OperatorRole, TokenRecover { // solium-disable-line max-len

  event MintFinished();

  bool public _mintingFinished = false;

  /**
   * @dev Tokens can be minted only before minting finished
   */
  modifier canMint() {
    require(!_mintingFinished);
    _;
  }

  /**
   * @dev Tokens can be moved only after minting finished or if you are an approved operator
   */
  modifier canTransfer(address from) {
    require(_mintingFinished || isOperator(from));
    _;
  }

  /**
   * @param name Name of the token
   * @param symbol A symbol to be used as ticker
   * @param decimals Number of decimals. All the operations are done using the smallest and indivisible token unit
   * @param cap Maximum number of tokens mintable
   */
  constructor(
    string name,
    string symbol,
    uint8 decimals,
    uint256 cap
  )
    ERC20Detailed(name, symbol, decimals)
    ERC20Capped(cap)
    public
  {}

  function mintingFinished() public view returns(bool) {
    return _mintingFinished;
  }

  function mint(
    address to,
    uint256 value
  )
    public
    canMint
    returns (bool)
  {
    return super.mint(to, value);
  }

  function transfer(
    address to,
    uint256 value
  )
    public
    canTransfer(msg.sender)
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    canTransfer(from)
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    _mintingFinished = true;
    emit MintFinished();
    return true;
  }

  function removeOperator(address account) public onlyOwner {
    _removeOperator(account);
  }

  function removeMinter(address account) public onlyOwner {
    _removeMinter(account);
  }
}
