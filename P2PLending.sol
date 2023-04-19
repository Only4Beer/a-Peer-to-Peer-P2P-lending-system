pragma solidity ^0.8.0;

contract P2PLending {
    
    // Struct to hold loan request details
    struct LoanRequest {
        uint256 amount;
        uint256 interest;
        uint256 dueDate;
        address borrower;
        address guarantor;
        bool accepted;
    }
    
    // Array of loan requests
    LoanRequest[] public loanRequests;
    
    // Mapping to store guarantees
    mapping(uint256 => mapping(address => uint256)) public guarantees;
    
    // Event to notify when a loan request is made
    event LoanRequested(uint256 indexed id, uint256 amount, uint256 interest, uint256 dueDate, address borrower);
    
    // Event to notify when a guarantee is placed
    event GuaranteePlaced(uint256 indexed id, address indexed guarantor, uint256 amount, uint256 interest);
    
    // Event to notify when a guarantee is withdrawn
    event GuaranteeWithdrawn(uint256 indexed id, address indexed guarantor);
    
    // Event to notify when a loan is granted
    event LoanGranted(uint256 indexed id, address indexed lender);
    
    // Event to notify when a loan is paid back
    event LoanPaid(uint256 indexed id, address indexed borrower, address indexed guarantor, address lender, uint256 amount, uint256 interest);
    
    // Function to make a loan request
    function requestLoan(uint256 _amount, uint256 _interest, uint256 _dueDate) public {
        LoanRequest memory newRequest = LoanRequest({
            amount: _amount,
            interest: _interest,
            dueDate: _dueDate,
            borrower: msg.sender,
            guarantor: address(0),
            accepted: false
        });
        loanRequests.push(newRequest);
        emit LoanRequested(loanRequests.length - 1, _amount, _interest, _dueDate, msg.sender);
    }
    
    // Function to place a guarantee on a loan request
    function placeGuarantee(uint256 _id, uint256 _interest) public payable {
        require(msg.value == loanRequests[_id].amount, "Guarantee amount should match loan request amount");
        require(loanRequests[_id].guarantor == address(0), "Guarantee has already been placed for this loan request");
        guarantees[_id][msg.sender] = _interest;
        loanRequests[_id].guarantor = msg.sender;
        emit GuaranteePlaced(_id, msg.sender, msg.value, _interest);
    }
    
    // Function to withdraw a guarantee
    function withdrawGuarantee(uint256 _id) public {
        require(loanRequests[_id].guarantor == msg.sender, "You are not the guarantor for this loan request");
        require(!loanRequests[_id].accepted, "Loan request has already been accepted");
        uint256 guaranteeAmount = guarantees[_id][msg.sender];
        guarantees[_id][msg.sender] = 0;
        payable(msg.sender).transfer(guaranteeAmount);
        loanRequests[_id].guarantor = address(0);
        emit GuaranteeWithdrawn(_id, msg.sender);
    }
    
    // Function to accept a loan request and grant a loan
    function grantLoan(uint256 _id) public payable {
        require(loanRequests[_id].borrower != address(0), "Loan request does not exist");
        require(!loanRequests[_id].accepted, "Loan request has already been accepted");
        require(loanRequests[_id].guarantor != address(0), "No guarantee has been placed for this loan request");
        require(msg.value == loanRequests[_id].amount, "Loan
