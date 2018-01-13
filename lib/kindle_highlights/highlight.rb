module KindleHighlights
  class Highlight
    attr_accessor :asin, :text, :location, :note, :page, :id


    # this function is to determine whether Amazon is giving a location or page number
    def pagenum(page)
      if page[0..3] == "Page" 
        return page.partition(':').last.lstrip
      else
        return nil
      end
    end

    def self.from_html_elements(book:, html_elements:)
      new(
        asin: book.asin,
        text: html_elements.children.search("div.kp-notebook-highlight").first.text.squish,
        location: html_elements.children.search("input#kp-annotation-location").first.attributes["value"].value,
        note: html_elements.children.search("span#note").first.text,
        page: html_elements.children.search("span#annotationHighlightHeader").first.text.partition('|').last.lstrip,
        id: html_elements.children.search("div.kp-notebook-highlight").first.attributes["id"].value.partition('highlight-').last.lstrip
      )
    end

    def initialize(asin:, text:, location:, note:, page:, id:)
      @asin = asin
      @text = text
      @location = location
      @note = note
      @page = pagenum(page)
      @id = id
    end

    def to_s
      text
    end
  end
end
