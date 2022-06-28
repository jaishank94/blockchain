// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventSys is ERC1155, Ownable {
    using SafeMath for uint256;

    mapping(uint256 => Event) public events;
    mapping(uint256=>string) private _uris;

    uint256[] public event_id_list;
    using Counters for Counters.Counter;

    Counters.Counter private _event_ids;

    struct Event {
        uint256 event_id;
        address owner;
        string title;
        string description;
        string image;
        uint64 total_tickets;
        uint64 available_tickets;
        uint128 ticket_price;
    }

    event EventCreated(uint256 event_id);

    modifier eventExists(uint256 event_id) {
        require(events[event_id].event_id == event_id, "Event with given ID not found.");
        _;
    }

    constructor() ERC1155("") {}

    function mint(string memory _uri, uint64 _tickets) public payable {
        uint256 tokenId = _event_ids.current();
        _mint(msg.sender, tokenId, _tickets, "");
        setTokenUri(tokenId, _uri);
    }

    function uri(uint256 tokenId) override public view  returns(string memory){
        return(_uris[tokenId]);
    }

    function setTokenUri(uint256 tokenId, string memory _uri)  internal {
        require(bytes(_uris[tokenId]).length == 0,"Cannot set uri twice");
        _uris[tokenId]=_uri;
    }

    function create_event(
        string memory _title,
        string memory _description,
        string memory _image,
        uint64 _num_tickets,
        uint128 _ticket_price,
        string memory _uri
    ) external {
        require(_num_tickets > 0, "Number of tickets cannot be zero.");
        require(_ticket_price > 0, "Ticket price cannot be zero.");

        _event_ids.increment();

        uint256 new_event_id = _event_ids.current();

        events[new_event_id].event_id = new_event_id;
        events[new_event_id].title = _title;
        events[new_event_id].description = _description;
        events[new_event_id].image = _image;
        events[new_event_id].total_tickets = _num_tickets;
        events[new_event_id].available_tickets = _num_tickets;
        events[new_event_id].ticket_price = _ticket_price;
        events[new_event_id].owner = msg.sender;


        event_id_list.push(new_event_id);
        mint(_uri, _num_tickets);
        emit EventCreated(new_event_id);
    }

    function get_tickets(uint256 event_id)
        external
        view
        eventExists(event_id) 
        returns (uint64)
    {
        return events[event_id].available_tickets;
    }

    function get_event_info(uint256 event_id)
        external
        view
        eventExists(event_id) 
        returns (
            string memory title,
            string memory description,
            string memory image,
            address owner,
            uint64 available_tickets,
            uint64 total_tickets,
            uint128 ticket_price
        )
    {
        Event memory e = events[event_id];
        return (
            e.title,
            e.description,
            e.image,
            e.owner,
            e.available_tickets,
            e.total_tickets,
            e.ticket_price
        );
    }

    function get_events() external view returns (uint256[] memory event_list) {
        return event_id_list;
    }
}
