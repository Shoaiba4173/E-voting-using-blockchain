// SPDX-License-Identifier: MIT 
pragma solidity >=0.4.25 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Types.sol";

contract Ballot {
    Types.Candidate[] public candidates;
    mapping(uint256 => Types.Voter) voter;
    mapping(uint256 => Types.Candidate) candidate;
    mapping(uint256 => uint256) internal votesCount;

    address electionChief;
    uint256 private votingStartTime;
    uint256 private votingEndTime;

    constructor(uint256 startTime_, uint256 endTime_) public {
        initializeCandidateDatabase_();
        initializeVoterDatabase_();
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        electionChief = msg.sender;
    }

    function getCandidateList(uint256 voterAadharNumber)
        public
        view
        returns (Types.Candidate[] memory)
    {
        Types.Voter storage voter_ = voter[voterAadharNumber];
        uint256 _politicianOfMyConstituencyLength = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) _politicianOfMyConstituencyLength++;
        }
        Types.Candidate[] memory cc = new Types.Candidate[](
            _politicianOfMyConstituencyLength
        );

        uint256 _indx = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) {
                cc[_indx] = candidates[i];
                _indx++;
            }
        }
        return cc;
    }

    function isVoterEligible(uint256 voterAadharNumber)
        public
        view
        returns (bool voterEligible_)
    {
        Types.Voter storage voter_ = voter[voterAadharNumber];
        if (voter_.age >= 18 && voter_.isAlive) voterEligible_ = true;
    }


    function didCurrentVoterVoted(uint256 voterAadharNumber)
        public
        view
        returns (bool userVoted_, Types.Candidate memory candidate_)
    {
        userVoted_ = (voter[voterAadharNumber].votedTo != 0);
        if (userVoted_)
            candidate_ = candidate[voter[voterAadharNumber].votedTo];
    }

    function vote(
        uint256 nominationNumber,
        uint256 voterAadharNumber,
        uint256 currentTime_
    )
        public
        votingLinesAreOpen(currentTime_)
        isEligibleVote(voterAadharNumber, nominationNumber)
    {
        // updating the current voter values
        voter[voterAadharNumber].votedTo = nominationNumber;

        // updates the votes the politician
        uint256 voteCount_ = votesCount[nominationNumber];
        votesCount[nominationNumber] = voteCount_ + 1;
    }

    function getVotingEndTime() public view returns (uint256 endTime_) {
        endTime_ = votingEndTime;
    }

    function updateVotingStartTime(uint256 startTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
    }


    function extendVotingTime(uint256 endTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime < currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }

    function getResults(uint256 currentTime_)
        public
        view
        returns (Types.Results[] memory)
    {
        require(votingEndTime < currentTime_);
        Types.Results[] memory resultsList_ = new Types.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Types.Results({
                name: candidates[i].name,
                partyShortcut: candidates[i].partyShortcut,
                partyFlag: candidates[i].partyFlag,
                nominationNumber: candidates[i].nominationNumber,
                stateCode: candidates[i].stateCode,
                constituencyCode: candidates[i].constituencyCode,
                voteCount: votesCount[candidates[i].nominationNumber]
            });
        }
        return resultsList_;
    }


    modifier votingLinesAreOpen(uint256 currentTime_) {
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
        _;
    }


    modifier isEligibleVote(uint256 voterAadhar_, uint256 nominationNumber_) {
        Types.Voter memory voter_ = voter[voterAadhar_];
        Types.Candidate memory politician_ = candidate[nominationNumber_];
        require(voter_.age >= 18);
        require(voter_.isAlive);
        require(voter_.votedTo == 0);
        require(
            (politician_.stateCode == voter_.stateCode &&
                politician_.constituencyCode == voter_.constituencyCode)
        );
        _;
    }

    modifier isElectionChief() {
        require(msg.sender == electionChief);
        _;
    }

function initializeCandidateDatabase_() internal {
        Types.Candidate[] memory candidates_ = new Types.Candidate[](14);

        // Andhra Pradesh
        candidates_[0] = Types.Candidate({
            name: "Chandra Babu Naidu",
            partyShortcut: "TDP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/tdp_qh1rkj.png",
            nominationNumber: uint256(727477314982),
            stateCode: uint8(10),
            constituencyCode: uint8(1)
        });
        candidates_[1] = Types.Candidate({
            name: "Jagan Mohan Reddy",
            partyShortcut: "YSRCP",
            partyFlag: "https://res.cloudinary.com/dj9ttsbgm/image/upload/v1648101065/ysrcp_sas311.png",
            nominationNumber: uint256(835343722350),
            stateCode: uint8(10),
            constituencyCode: uint8(1)
        });
        for (uint256 i = 0; i < candidates_.length; i++) {
            candidate[candidates_[i].nominationNumber] = candidates_[i];
            candidates.push(candidates_[i]);
        }
    }

    function initializeVoterDatabase_() internal {
        // Andhra Pradesh
        voter[uint256(482253918244)] = Types.Voter({
            name: "harshith",
            aadharNumber: uint256(482253918244),
            age: uint8(21),
            stateCode: uint8(10),
            constituencyCode: uint8(1),
            isAlive: true,
            votedTo: uint256(0)
        });
        voter[uint256(532122269467)] = Types.Voter({
            name: "shoiab",
            aadharNumber: uint256(532122269467),
            age: uint8(37),
            stateCode: uint8(10),
            constituencyCode: uint8(1),
            isAlive: false,
            votedTo: uint256(0)
        });
    }
}
