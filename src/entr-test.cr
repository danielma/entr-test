# this is our inspiration

# guard :elixir do
#   watch(%r{^test/(.*)_test\.exs})
#   watch(%r{^lib/(.+)\.ex$})           { |m| "test/#{m[1]}_test.exs" }
#   watch(%r{^test/test_helper.exs$})   { "test" }
# end

base_command = "mix test"

unless ARGV.size > 0
  puts "Please pass at least one file as the first argument"
  exit 1
end

$matches: Hash(Regex, Proc(Regex::MatchData, String) | String | Bool) = {
  %r(^test/(.*)_test\.exs)   => true,
  %r(^lib/(.+)\.ex$)         => ->(m: Regex::MatchData) { "test/lib/#{m[1]}_test.exs" },
  %r(^web/(.+)\.ex$)         => ->(m: Regex::MatchData) { "test/#{m[1]}_test.exs" },
  %r(^test/test_helper.exs$) => "",
}

def get_match(file)
  $matches.each do |pattern, runner|
    match = file.match(pattern)

    return {file, runner, match} if match
  end

  nil
end

def try_match(file)
  return nil unless match = get_match(file)

  file = match[0]
  runner = match[1]
  match = match[2]

  case runner
  when Proc
    runner.as(Proc).call(match)
  when true
    file
  else
    runner
  end
end

file = ARGV[0]
file = file[(Dir.current.size + 1)..-1] if file.starts_with?(Dir.current)
test_file = try_match(file)

exit unless test_file

args = ["test", test_file.as(String)] + ARGV[1..-1]
puts "mix #{args.join(" ")}"
system "mix", args
