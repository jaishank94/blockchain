// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Events is ERC721, ERC721Enumerable, ERC721URIStorage {
    using SafeMath for uint256;
    // uint256 public constant mintPrice = 0;
    mapping(uint256 => Event) public events;
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

    // modifier eventExists(uint256 event_id) {
    //     require(events[event_id], "Event with given ID not found.");
    //     _;
    // }

    constructor() ERC721("EventCoin", "ECN") {}

    function mint(string memory _uri) public payable {
        uint256 tokenId = _event_ids.current();
        // uint256 mintIndex = totalSupply();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
        mint(_uri);
        emit EventCreated(new_event_id);
    }

    function get_tickets(uint256 event_id)
        external
        view
        returns (uint64)
    {
        return events[event_id].available_tickets;
    }

    function get_event_info(uint256 event_id)
        external
        view
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
