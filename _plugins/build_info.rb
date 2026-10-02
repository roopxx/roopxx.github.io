# Exposes the commit being built and the Chennai time of the build as
# `site.build`, for the footer line. On GitHub Actions the commit comes from
# GITHUB_SHA; locally it falls back to the checked-out HEAD.
Jekyll::Hooks.register :site, :after_init do |site|
  sha = ENV['GITHUB_SHA'].to_s
  sha = `git rev-parse HEAD 2>/dev/null`.strip if sha.empty?
  now = Time.now.getlocal('+05:30')

  site.config['build'] = {
    'sha' => sha,
    'short_sha' => sha[0, 7],
    'time' => now.strftime('%H:%M'),
    'datetime' => now.strftime('%Y-%m-%dT%H:%M:%S%:z')
  }
end
