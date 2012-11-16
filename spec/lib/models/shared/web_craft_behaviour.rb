shared_examples :WebCraft do

  let (:subject_accessor)  { subjectClass.name.underscore } # eg: 'twitter_craft' - used for craft.twitter_craft with craft.send(subject_accessor)

  # id specifications
  specify { subject.web_craft_id.should be_an_instance_of String }
  specify { subject.web_craft_id.should eq subject_id.to_s }
  specify { subject.id_for_fetching.should eq subject_handle }

  # test a subject (instance)
  it :@provider do
    subject.provider.should equal provider_symbol
  end
  it :@@provider do
    subjectClass.provider.should equal provider_symbol
  end

  it :@provider_key do
    subject.provider_key.should eq provider_key
  end
  it :@@provider_key do
    subjectClass.provider_key.should eq provider_key
  end

  context :invalid_id do
    it :@@materialize do
      wc = subjectClass.materialize( {has_no_web_craft_id:true} )
      wc.should be_nil
    end
  end

  context :when_subject_doesnt_exist do
    it :@@materialize do
      wc = subjectClass.materialize(subject_attributes)
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
    end

    it :@@materialize_works_with_integer_id do
      wc = subjectClass.materialize({web_craft_id: subject_id.to_i})
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
    end

    it :@@materialize_works_with_string_id do
      wc = subjectClass.materialize({web_craft_id: subject_id.to_s})
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
    end

    it :@@materialize_craft_is_nil do
      wc = subjectClass.materialize(subject_attributes)
      wc.should_not be_nil
      wc.craft.should be_nil
    end
  end

  context :when_subject_already_exists do
    before(:all) do
      c = Craft.new
      c.bind(subject)
      c.save
    end
    after(:all) do
      subject.craft.delete # delete the parent craft
    end

    it :@@materialize_works_with_integer_id do
      wc = subjectClass.materialize({web_craft_id: subject_id})
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
      wc.username.should eq subject_handle
    end

    it :@@materialize_craft_exists do
      wc = subjectClass.materialize({ web_craft_id: subject_id })
      wc.should_not be_nil
      wc.craft.should_not be_nil
      wc.craft.send(subject_accessor).should eq wc
    end

  end

  it :@geocodes

  # def geocode_this_location!
end
