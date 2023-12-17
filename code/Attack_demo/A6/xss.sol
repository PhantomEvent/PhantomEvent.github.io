// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XSS {

    event XSS(string xss);


    function triggerXSS(string memory _xss) public {
        emit XSS(_xss);
    }
}

