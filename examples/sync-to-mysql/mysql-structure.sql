-- --------------------------------------------------------

--
-- Table structure for table `kindle_books`
--

CREATE TABLE IF NOT EXISTS `kindle_books` (
  `asin` varchar(100) NOT NULL,
  `author` text NOT NULL,
  `title` text NOT NULL,
  `book_cover` text NOT NULL,
  `last_annotation` date NOT NULL,
  `date_created` date NOT NULL,
  PRIMARY KEY (`asin`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `kindle_highlights`
--

CREATE TABLE IF NOT EXISTS `kindle_highlights` (
  `highlight_id` varchar(100) NOT NULL,
  `book_asin` varchar(100) NOT NULL,
  `date_created` date NOT NULL,
  `location` int(10) NOT NULL,
  `pagenumber` int(10) NOT NULL,
  `highlighted_text` text NOT NULL,
  `note` text NOT NULL COMMENT 'optional',
  PRIMARY KEY (`highlight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;