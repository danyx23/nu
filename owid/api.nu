# Fetches the metadata for the indicator with the given id
export def metadata [
    indicatorId: int # Id of the indicator
] {
    http get $"https://api.ourworldindata.org/v1/indicators/($indicatorId).metadata.json"
}

# Fetches the data for the indicator with the given id.
# Returns a table with columns entity, value and year. Note that entity is a number.
export def data [
    indicatorId: int # Id of the indicator
] {
    let data = http get $"https://api.ourworldindata.org/v1/indicators/($indicatorId).data.json"
    # zip creates a list of 2-tuple lists and it doesn't support more than one list so reformatting a record with 3 keys, entities, years and values, each
    # having a long array is a bit tedious:
    $data.entities
    | zip $data.values
    | each { {entity: $in.0 value: $in.1} }
    | zip $data.years
    | each { { entity: $in.0.entity value: $in.0.value year: $in.1 } }

}

# Fetches the metadata and data for the indicator with the given id and
# expands the data table to include not just entity, value and year but also entityName and entityCode.
export def indicator [
    indicatorId: int # Id of the indicator
] {
    let metadata = metadata $indicatorId
    let data = data $indicatorId
    let lookupTable = $metadata.dimensions.entities.values
    let extendedData = $data | join $lookupTable entity id --left | reject id | rename --column { name: entityName code: entityCode}
    { metadata: $metadata data: $extendedData }
}

# Fetches a chart config from the ourworldindata.org website given a slug
# and returns it as a record.
export def chart [
    chartSlug: string # slug of the chart
] {
    let chartPage = http get $"https://ourworldindata.org/grapher/($chartSlug)"
    let relevantLines = (
        $chartPage
        | lines
        | skip until { |it|  $it | str contains "//EMBEDDED_JSON" }
        | skip 1
        | take until { |it| $it | str contains "//EMBEDDED_JSON" }
        | str join "\n"
    )
    let chartConfig = $relevantLines | from json
    $chartConfig
}

# Fetches the indicators used in a chart and returns them as a table with columns metadata and data
export def chart-indicators [
    chartSlug: string # slug of the chart
] {
    let chartConfig = chart $chartSlug
    let indicators = $chartConfig.dimensions | par-each { |it| indicator ($it.variableId | into int) | insert "property" $it.property }
    $indicators
}