sub MAIN($file, $order = 2, $maxwords = 75, $finalword = "".Str, $ignorenl=False) {
	my %table = markov_read($file, $order);
	my $output = markov_gen(%table, $order, $maxwords, $finalword, $ignorenl);
	put($output);
	exit(0);
}

# Read the file from source, put it in a data structure,
#  save the data structure to file.
sub markov_read($file, $order) {
	my @input = $file.IO.lines;
	my $empty = "".Str;
	my @prefix;
	my %table;

	# Fill an array with empty strings to quickly reset the prefix
	my @empty_array;
	loop (my $i = 0; $i < $order; $i++) {
		@empty_array[$i] = $empty;
	}

	for @input -> $line {
		@prefix = @empty_array;

		# Keep a final empty string to signify line breaks
		my @words = $line.words;
		@words.append($empty);

		# Add the entire line
		for @words -> $word {
			if (!defined(%table{@prefix.join})) {
				%table.append(@prefix.join => [$word]);
			} else {
				%table{@prefix.join}.append($word);
			}

			@prefix.shift;
			@prefix[$order - 1] = $word;
		}
	}

	return %table;
}

# Generate a string based on the given table.
sub markov_gen(%table, $order, $maxwords, $finalword, $ignorenl) {
	my @prefix = [];
	my @output = [];
	my $empty = "".Str;
	# Fill the prefix with empty entries to get a first word in the string.
	loop (my $i = 0; $i < $order; $i++) {
		@prefix[$i] = $empty;
	}

	my $wordc = 0;
	my $index = %table{@prefix.join}.elems.rand.Int;
	my $nextword = %table{@prefix.join}[$index];
	while ($nextword !eq $finalword && $wordc < $maxwords) { 
		if ($nextword !eq $empty) {
			@output.append($nextword);
		} elsif (!$ignorenl) {
			@output.append("\n");
		}

		@prefix.shift;
		@prefix[$order - 1] = $nextword;

		$index = %table{@prefix.join}.elems.rand.Int;
		$nextword = %table{@prefix.join}[$index];
		$wordc++;
	}

	return @output.join(" ");
}
