library( tidyverse ) 
library( magrittr )
library( lubridate )

library( ggplot2 )
library( ggthemes )
library( ggtext )

library( countrycode )

library( showtext )

library( grimoire ) # devtools::install_github("weirddatascience/grimoire")

# Fonts
#font_add( "main", regular="EurostileNextLTProLightExt.otf", bold="EurostileNextLTProExtended.otf")
font_add( "main", regular="Spectral-Regular.ttf", bold="Spectral-Bold.ttf", italic="Spectral-Italic.ttf", bolditalic="Spectral-BoldItalic.ttf" )
showtext_auto()

# Set a start and end date for cutoff.
start_date <- "1970-01-01"
end_date <- "2023-01-01"

# Load data
# (Query stored in patent_monthly_count.sql.)
patent_counts_raw <-
	read_csv( "data/monthly_country_patents.csv", show_col_types=FALSE )

# Several rows have 0 as the date. Must be a missing filing date.
patent_counts <-
	patent_counts_raw %>%
	filter( month != 0 ) 

# Convert the month, stored as an integer, to a date.
patent_counts <-
	patent_counts %>%
	mutate( date = as.character( month / 100 ) ) %>%
	mutate( date = ym( date ) ) %>%
	select( -month ) %>%
	relocate( date, country, patent_count )

# Filter to >=start_date
patent_counts <-
	patent_counts %>%
	filter( date >= start_date ) 

# Summarize to a global monthly count
patents_global <-
	patent_counts %>%
	group_by( date ) %>%
	summarize( patent_count=sum( patent_count ) ) %>%
	ungroup %>%
	mutate( country="All" )

# (Filter to most prolific 5 countries)
top_five <-
	patent_counts %>%
	group_by( country ) %>%
	summarise( total = sum( patent_count ) ) %>%
	arrange( desc( total ) ) %>%
	head( 5 ) %>%
	extract2( "country" )

custom_country_codes <-
	c(	"EP" = "European Patent Office" )

patent_counts_subset <-
	patent_counts %>%
	filter( country %in% top_five ) %>%
	mutate( country = countrycode( country, origin="iso2c", dest="country.name", custom_match= custom_country_codes ) ) %>%
	filter( date < end_date ) # Cut off due to duration of patent filing process

patent_counts_total <-
	bind_rows( patent_counts_subset, patents_global ) %>%
	filter( date < end_date )

# Remove global count from dataset -- it's not helpful
patent_counts_subset <-
	patent_counts_subset %>%
	filter( country != "All" )

# Plot
patent_plot <-
	ggplot( patent_counts_subset, aes( x=date, y=patent_count, fill=country, colour=country ) ) + 
	geom_line( aes( x=date, y=patent_count, colour=country ), show.legend=TRUE ) +
	labs( x="Priority Date", y="Monthly Patent Count" ) +
	#ggtitle( "Total count of patents _across all sectors, including non-wildlife,_ for five most prolific filing regions" ) +
	ggtitle( "Total count of patents _across all sectors_ for five most prolific filing regions" ) +
	scale_y_continuous( labels=scales::comma ) + 
	scale_fill_manual( name="Country",
							  	values=c(	#`All`="#cccccc", 
												`China`=weird_colours[["blood red"]],
												`European Patent Office`=weird_colours[["weird blue"]],
												`Japan`=weird_colours[["ufo green"]],
												`South Korea`=weird_colours[["pumpkin orange"]],
												`United States`=weird_colours[["purpureus"]] )
											  ) +
	scale_colour_manual( name="Country",
							  	values=c(	#`All`="#cccccc", 
												`China`=weird_colours[["blood red"]],
												`European Patent Office`=weird_colours[["weird blue"]],
												`Japan`=weird_colours[["ufo green"]],
												`South Korea`=weird_colours[["pumpkin orange"]],
												`United States`=weird_colours[["purpureus"]] )
											  ) +
	theme_few() +
	theme( 
			text = element_text( family="main" ),
			plot.title = element_markdown( size=14, hjust=0, color="#333333", family="main", face="bold" ),
			axis.text = element_text( size=14, hjust=0, color="#333333", family="main" ),
			axis.title.x = element_text( size=14, color="#333333", family="main", face="bold", margin = margin(t = 20, r = 0, b = 0, l = 0)  ),
			axis.title.y = element_text( size=14, color="#333333", family="main", face="bold", angle=90, margin = margin(t = 0, r = 20, b = 0, l = 0) ),
			strip.text = element_text(size = 14 ),
			legend.text = element_text( size=14, family="main" ),
			legend.title = element_text( size=14, family="main", face="bold" ),
			legend.position = "bottom" )

## Ensure output directory exists
dir.create( "output", showWarnings=FALSE )

message( cyan( "Saving global patent counts. (PDF)." ) )
ggsave( 	"output/global_count_plot.pdf", 
		 patent_plot,
		 width = 16,
		 height = 9 )
