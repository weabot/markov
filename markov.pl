sub MAIN($file, $order = 2, $maxwords = 75, $finalword = "") {
	my %table = markov_read($file, $order);
	my $output = markov_gen(%table, $order, $maxwords, $finalword);
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

	loop (my $i = 0; $i < $order; $i++) {
		@prefix[$i] = $empty;
	}

	for @input -> $line {
		my @words = $line.words;

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
	while ($word !eq $finalword && $wordc < $maxwords) { 
		$index = %table{@prefix.join}.elems.rand.Int;
		$word = %table{@prefix.join}[$index];

		if ($word !eq $empty) {
			@output.append($word);
			@prefix.shift;
			@prefix[$order - 1] = $word;
			$wordc++;
		}
	}

	return @output.join(" ");
}
