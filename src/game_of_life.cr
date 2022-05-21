require "ncurses"

class Life
  DIR = [{0, 1}, {1, 0}, {0, -1}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

  getter h : Int32
  getter w : Int32
  getter g : Array(Array(Bool))

  delegate "[]", to: g

  def initialize(@h, @w)
    @g = Array.new(h) { Array.new(w, false) }
  end

  def seed!
    h.times do |y|
      w.times do |x|
        next if rand < 0.7
        g[y][x] = true
      end
    end
  end

  def nex!
    tmp = Array.new(h) { Array.new(w, false) }
    h.times do |y|
      w.times do |x|
        tmp[y][x] = case g[y][x]
                    in true  then neighbour(y, x).in?(2..3)
                    in false then neighbour(y, x) == 3
                    end
      end
    end
    @g = tmp
  end

  def neighbour(y, x)
    DIR.sum do |dy, dx|
      ny, nx = y + dy, x + dx
      next 0 if outside?(ny, nx)
      g[ny][nx].to_unsafe
    end
  end

  def outside?(y, x)
    y < 0 || h <= y || x < 0 || w <= x
  end
end

NCurses.open do
  h, w = NCurses.maxyx
  life = Life.new(h, w)

  NCurses.cbreak
  NCurses.noecho
  NCurses.keypad(true)
  NCurses.start_color
  NCurses.curs_set(0)

  # pair = NCurses::ColorPair.new(1).init(NCurses::Color::RED, NCurses::Color::BLACK)
  # NCurses.bkgd(pair)

  life.seed!
  loop do
    NCurses.erase
    NCurses.box(v: '|', h: '=')

    (1...h - 1).each do |y|
      (1...w - 1).each do |x|
        next unless life[y][x]
        NCurses.move(y, x)
        NCurses.addstr("o")
      end
    end
    life.nex!

    NCurses.refresh

    sleep 100.milliseconds
  end

  NCurses.notimeout(true)
  NCurses.getch
end
