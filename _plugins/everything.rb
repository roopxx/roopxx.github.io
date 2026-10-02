# Builds `site.data.everything`: every dated note, weekly entry, work write-up
# and now entry in one newest-first stream, plus the geometry of a
# `git log --graph` style drawing of it. Runs on every Jekyll build, so the
# page cannot drift from the content.
#
# The graph: one lane per kind of entry. The kind with the oldest entry is the
# trunk (lane 0) and runs the full height. Every other kind branches off the
# trunk just below its oldest entry and ends at its newest. Rows have a fixed
# height, so the SVG lines and the HTML rows line up without any script.
module Jekyll
  class EverythingGenerator < Generator
    safe true
    priority :low

    KINDS = { 'posts' => 'note', 'weekly' => 'week', 'work' => 'work', 'now' => 'now' }.freeze
    LANE_NAMES = { 'note' => 'notes', 'week' => 'weekly', 'work' => 'work', 'now' => 'now' }.freeze
    ROW = 36    # row height in SVG units (1 unit = 1/16 rem)
    LANE = 14   # distance between lanes
    PAD = 8     # trunk's distance from the left edge
    WEEK = 7 * 24 * 60 * 60

    def generate(site)
      entries = collect(site)
      site.data['everything'] = entries.empty? ? { 'rows' => [] } : layout(entries, site.time)
    end

    private

    def collect(site)
      KINDS.flat_map do |name, kind|
        collection = site.collections[name]
        next [] unless collection

        collection.docs.filter_map do |doc|
          date = doc.data['date']
          # Jekyll stamps undated entries with the build time; leave those out.
          next if date.nil? || date == site.time

          {
            'kind' => kind,
            # Now entries have no title of their own; name them by month.
            'title' => kind == 'now' ? date.strftime('Now, %B %Y') : doc.data['title'],
            'url' => doc.url,
            'time' => date.to_time,
            'blurb' => doc.data['summary'] || doc.data['description']
          }
        end
      end.sort_by { |e| e['time'] }.reverse
    end

    def layout(entries, now)
      # Lanes in order of first appearance, oldest first.
      kinds = entries.reverse.map { |e| e['kind'] }.uniq
      lane_of = kinds.each_with_index.to_h

      rows = []
      year = nil
      entries.each do |e|
        if e['time'].year != year
          year = e['time'].year
          rows << { 'type' => 'year', 'label' => year.to_s }
        end
        rows << {
          'type' => 'entry',
          'kind' => e['kind'],
          'title' => e['title'],
          'url' => e['url'],
          'blurb' => e['blurb'],
          'date' => e['time'].strftime('%b %-d'),
          'lane' => lane_of[e['kind']],
          'fresh' => e['time'] >= now - WEEK && e['time'] <= now
        }
      end

      x = ->(lane) { PAD + lane * LANE }
      y = ->(row) { row * ROW + ROW / 2 }
      span = kinds.map do |kind|
        idx = rows.each_index.select { |i| rows[i]['kind'] == kind }
        [idx.first, idx.last]
      end

      paths = []
      trunk_top = span[0][0]
      span.each_with_index do |(top, bottom), lane|
        next if lane.zero?

        fork = bottom + 1
        trunk_top = [trunk_top, fork].min
        paths << format(
          'M%<x0>d,%<y1>d C%<x0>d,%<c1>d %<xk>d,%<c2>d %<xk>d,%<y0>d V%<yt>d',
          x0: x[0], y1: y[fork], c1: y[fork] - ROW / 2,
          xk: x[lane], c2: y[bottom] + ROW / 2, y0: y[bottom], yt: y[top]
        )
      end
      paths.unshift(format('M%<x>d,%<a>d V%<b>d', x: x[0], a: y[trunk_top], b: y[span[0][1]]))

      {
        'rows' => rows,
        'lanes' => kinds.map { |k| LANE_NAMES[k] },
        'paths' => paths,
        'width' => PAD * 2 + (kinds.size - 1) * LANE,
        'height' => rows.size * ROW,
        'row' => ROW, 'lane' => LANE, 'pad' => PAD
      }
    end
  end
end
