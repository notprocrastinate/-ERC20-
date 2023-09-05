// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './SafeMath.sol';
import './ERC20.sol';

contract LP is ERC20 {
    using SafeMath for uint;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address _owner) public view override returns (uint256) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_balances[_from] >= _value, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[_from] -= _value;
            _balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(msg.sender == _to, "ERC20: transfers to another address than caller not allowed");

        uint256 _allowance = allowance(_from, msg.sender);
        require(_allowance >= _value, "ERC20: insufficient allowance");

        unchecked {
            _approve(_from,_to,_allowance - _value);
        }

        _transfer(_from, msg.sender, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
        assert((_value == 0) || (allowance(msg.sender, _spender) == 0));
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowed[_owner][_spender];
    }

    function _mint(address to, uint value) external {
        _totalSupply = _totalSupply.add(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) external {
        _balances[from] = _balances[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }
}
