%Image::ExifTool::UserDefined = (


'Image::ExifTool::Composite' => {
#----------START copy the following into your .ExifTool_config if you have other Composites already defined----------#
	FLACBitrate => {
		Require => {
			0 => 'FileSize',
			1 => 'SampleRate',
			2 => 'TotalSamples',
		},
	ValueConv => '($val[0] * 8) / ($val[2] / $val[1])',
	PrintConv => 'sprintf("%.0f", ($val / 1000))',
	},
#-----------END copy the preceding into your .ExifTool_config if you have other Composites already defined------------#
},


#-----------end config-------------#
);
1;
#---------keep at bottom----------#
