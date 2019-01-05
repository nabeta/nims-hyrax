class ComplexRelation < ActiveTriples::Resource
  include CommonMethods

  configure type: ::RDF::Vocab::PROV.Association
  property :title, predicate: ::RDF::Vocab::DC.title
  property :url, predicate: ::RDF::Vocab::MODS.locationUrl
  property :complex_identifier, predicate: ::RDF::Vocab::MODS.identifierGroup,
            class_name:"ComplexIdentifier"
  accepts_nested_attributes_for :complex_identifier
  property :relationship, predicate: ::RDF::Vocab::EBUCore.roleDefinition

  ## Necessary to get AT to create hash URIs.
  def initialize(uri, parent)
    if uri.try(:node?)
      uri = RDF::URI("#relation#{uri.to_s.gsub('_:', '')}")
    elsif uri.start_with?("#")
      uri = RDF::URI(uri)
    end
    super
  end

end
