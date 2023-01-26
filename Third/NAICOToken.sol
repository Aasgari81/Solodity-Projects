pragma solidity 0.8.17;

//ERC20 token
interface ERC20 
{
    event Transfer (address indexed from, address indexed, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address from, address to, uint256 amount) external returns (bool);
    function allowance (address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // From now on in this interface the data is meta data
    function name() external view returns (string memory);
    function Symbol() external view returns (string memory);
    function decimal() external view returns (uint256);
}

contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address is invalid");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}

contract NAICOToken is ERC20, Ownable
{
    event Paused();
    event UnPaused();
    
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    string private constant _name = "NAICO";
    string private constant _symbol = "NAI";
    uint256 private constant _decimals =15;
    uint256 private hardcap = 25000000000 * (10**_decimals); // 25 bilion
    uint256 private _totalsupply = 25000000000 ;
    bool private pause = false;
    modifier paused()
    {
        require(pause);
        _;
    }
    function name() public view virtual override paused returns (string memory){
        return _name;
    }
    function Symbol() public view virtual override paused returns (string memory){
        return _symbol;
    }
    
    function decimal() public view virtual override paused returns (uint256){
        return _decimals;
    }
    
    function totalSupply() public view virtual override paused returns (uint256){
        return _totalsupply;
    }
    function balanceOf (address account) public view virtual override paused returns (uint256) {
        return _balances[account];
    }
    function transfer (address from, address to, uint256 amount) public virtual override paused returns (bool)
    {
       _transfer(msg.sender, to, amount);
       return true;
    }
    function transferFrom (address from, address to, uint256 amount) public virtual override paused returns (bool)
    {
        _transfer(from, to, amount);
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }

        return true;
    }
    function _transfer (address sender, address reciever, uint256 amount) internal virtual paused
    {
        require (sender != address(0), "Invalid sender address");
        require (reciever != address(0), "Invalid reciever address");
        uint256 senderBalance = _balances[sender];
        require (senderBalance >= amount, "Not enough balance");
        unchecked {
            _balances[sender] -= amount;

        }
        _balances[reciever] += amount;
        emit Transfer(sender, reciever, amount);
    }
    function allowance(address owner, address spender) public virtual override view paused returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function _approve (address owner, address spender, uint256 amount) internal virtual paused
    {
        require(owner != address(0), "Invalid address");
        require(spender != address(0), "Invalid address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve (address to, uint256 amount) public virtual override paused returns (bool)
    {
        _approve(msg.sender, to, amount);
        return true;
    }
    function Pause()  public
    {
        pause = true;
        emit Paused();
    }
    function unPause() public
    {
        pause = false;
        emit UnPaused();
    }
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalsupply -= amount;

        emit Transfer(account, address(0), amount);
    }
    
    
}
