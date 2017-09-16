sub MAIN($file, $order = 2, $maxwords = 75, $finalword = "") {
	my %table = markov_read($file, $order);
	my $output = markov_gen(%table, $order, $maxwords, $finalword);
	put($output);
	exit(0);
}

# Read the file from source, put it in a data structure,
#  save the data structure to file.
sub markov_read($file, $order) {
	my $input = $file.IO.slurp;
	my $empty = "".Str;
	my @prefix;
	my %table;

	loop (my $i = 0; $i < $order; $i++) {
		@prefix[$i] = $empty;
	}

	my @words = $input.words;
	my $key;

	# Add the entire line
	for @words -> $word {
		$key = @prefix.join;

		if (defined(%table{$key})) {
			%table{$key}.append($word);
		} else {
			%table.append($key => [$word]);
		}

		@prefix.shift;
		@prefix[$order - 1] = $word;
	}

	return %table;
}

# Generate a string based on the given table.
sub markov_gen(%table, $order, $maxwords, $finalword) {
	my @prefix = [];
	my @output = [];
	my $empty = "".Str;

	# Fill the prefix with empty entries to get a first word in the string.
	loop (my $i = 0; $i < $order; $i++) {
		@prefix[$i] = $empty;
	}

	my $wordc = 0;
	my $index = %table{@prefix.join}.elems.rand.Int;
	my $word = %table{@prefix.join}[$index];
	my $key;
	while ($word !eq $finalword && $wordc < $maxwords) { 
		$key = @prefix.join;
		$index = %table{$key}.elems.rand.Int;
		$word = %table{$key}[$index];

		@output.append($word);
		@prefix.shift;
		@prefix[$order - 1] = $word;
		$wordc++;
	}

	return @output.join(" ");
}
