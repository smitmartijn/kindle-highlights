# Example using kindle_highlights to retrieve your Kindle books & highlights and store them in MySQL
# Martijn Smit
# Contact: https://twitter.com/smitmartijn

require_relative 'kindle-highlights/lib/kindle_highlights'
require 'mysql2'
require 'date'

# MySQL & Amazon login details
require_relative 'config'

# Enable this for more printing
debug = false

# Initiate MySQL connection
mysql_client = Mysql2::Client.new(:host => @db_host, :username => @db_user, :password => @db_pass, :database => @db_name)

# Prepare MySQL statements to insert books and highlights
sth_new_book = mysql_client.prepare("INSERT IGNORE INTO kindle_books (asin, author, title, book_cover, last_annotation, date_created) VALUES (?, ?, ?, ?, ?, NOW())")
sth_new_highlight = mysql_client.prepare("INSERT IGNORE INTO kindle_highlights (highlight_id, book_asin, date_created, location, pagenumber, highlighted_text, note) VALUES (?, ?, NOW(), ?, ?, ?, ?)")

# Login into Amazon (read.amazon.com)
kindle = KindleHighlights::Client.new(
  email_address: @amazon_email, 
  password: @amazon_password
)

# Stats!
discovered_books = 0
discovered_highlights = 0
new_books = 0
new_highlights = 0

# Get all books 
books = kindle.books

# Go through each book and 
books.each do |book, title|
  discovered_books += 1

  if debug == true
    print "Asin: #{book.asin}\n"
    print "Title: #{book.title}\n"
    print "Author: #{book.author}\n"
    print "Cover: #{book.cover_image_url}\n"
    print "Last Annotated: #{book.last_annotated}\n"
  end

  # Parse date, as it's something like this: Friday December 29, 2017
  date_last_annotated = Date.parse(book.last_annotated)

  # Insert book!
  result_new_book = sth_new_book.execute(book.asin, book.author, book.title, book.cover_image_url, date_last_annotated.to_s)

  # If the query actually did something, we inserted a new book!
  if mysql_client.affected_rows > 0
    new_books += 1
  end

  # if there hasn't been a highlight made in the last 2 days, skip retrieving the highlights
  if date_last_annotated < Date.today - 2
    next
  end

  # retrieve highlights
  highlights = kindle.highlights_for(book.asin)
  
  # sanity check
  if highlights.respond_to?('each')
    # go through each highligh and store it in the database
    highlights.each do |highlight|
      discovered_highlights += 1

      if debug == true
        print "Text: #{highlight.text}\n"
        print "ID: #{highlight.id}\n"
        print "Location: #{highlight.location}\n"
        print "Note: #{highlight.note}\n"
        print "Page: #{highlight.page}\n"
        print "\n-----------------\n"
      end

      result_new_highlight = sth_new_highlight.execute(highlight.id, book.asin, highlight.location, highlight.page, highlight.text, highlight.note)

      # If the query actually did something, we inserted a new highlight!
      if mysql_client.affected_rows > 0
        new_highlights += 1
      end 
    end # highlights.each do |highlight|
  end # if highlights.respond_to?('each')
end # books.each do |book, title|

# Housekeeping
date_today = DateTime.now.to_s
print "Running on #{date_today}\n"
print "Discovered books: #{discovered_books}\n"
print "Discovered highlights: #{discovered_highlights}\n"
print "Added new books: #{new_books}\n"
print "Added new highlights: #{new_highlights}\n"
print "-----------------\n"

