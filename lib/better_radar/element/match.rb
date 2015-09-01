class BetterRadar::Element::Match < BetterRadar::Element::Entity

  attr_accessor :betradar_match_id, :off, :sport_id, :round, :live_multi_cast, :live_score, :competitors, :bets, :bet_results, :date, :scores, :result_comment, :goals, :cards, :probabilities, :neutral_ground

  def initialize
    self.competitors = []
    self.bets = []
    self.scores = []
    self.goals = []
    self.cards = []
    self.bet_results = []
    self.probabilities = []
  end

   # Oh good god refactor this
  def assign_attributes(attributes, current_element, context)

    attributes.each do |attribute|
      attribute_name = attribute.first
      attribute_value = attribute.last

      case attribute_name
      when "BetradarMatchID"
        self.betradar_match_id = attribute_value
      when "ID", "SUPERID", "Language"
        if context.include?("Competitors")
          self.competitors.last[attribute_name.downcase.to_sym] = attribute_value
        end
      when "Type"
        if context.include?("Goal")
          self.goals.last.type = attribute_value
        elsif context.include?("Competitors")
          self.competitors.last[:type] = attribute_value
        elsif context.include?("Score")
          self.scores.last[:type] = attribute_value
        elsif context.include?("Card")
          self.cards.last.type = attribute_value
        elsif context.include?("PR")
        end
      when "OddsType"
        if context.include?("MatchOdds")
          self.bets.last.type = attribute_value
        elsif context.include?("BetResult")
          self.bet_results.last.type = attribute_value
        elsif context.include?("PR")
          self.probabilities.last.type = attribute_value
        end
      when "OutCome"
        if context.include?("MatchOdds")
          self.bets.last.odds.last.outcome = attribute_value
        elsif context.include?("BetResult")
          self.bet_results.last.outcome = attribute_value
        elsif context.include?("P")
          self.probabilities.last.outcome_probabilities.last[:outcome] = attribute_value
        end
      when "Id"
        if current_element == "Goal"
          self.goals.last.id = attribute_value
        elsif current_element == "Card"
          self.cards.last.id = attribute_value
        elsif current_element == "Player"
          if context.include?("Goal")
            self.goals.last.player.id = attribute_value
          elsif context.include?("Card")
            self.cards.last.player.id = attribute_value
          end
        end
      when "ScoringTeam"
        self.goals.last.scoring_team = attribute_value
      when "Team1"
        self.goals.last.team1 = attribute_value
      when "Team2"
        self.goals.last.team2 = attribute_value
      when "Time"
        if current_element == "Goal"
          self.goals.last.time = attribute_value
        elsif current_element == "Card"
          self.cards.last.time = attribute_value
        end
      when "Name"
        if context.include?("Goal")
          self.goals.last.player.name = attribute_value
        elsif context.include?("Card")
          self.cards.last.player.name = attribute_value
        end
      when "SpecialBetValue"
        if context.include?("BetResult")
          self.bet_results.last.special_value = attribute_value
        elsif context.include?("Probabilities")
          self.probabilities.last.outcome_probabilities.last[:special_value] = attribute_value
        end
      when "Status"
        self.bet_results.last.status = attribute_value
      when "VoidFactor"
        self.bet_results.last.void_factor = attribute_value
      else
        warn "#{self.class} :: attribute: #{attribute_name} on #{current_element} not supported"
      end
    end
  end

  def assign_content(content, current_element, context)
    case current_element
    when "Odds"
      self.bets.last.odds.last.value = content
    when "Score"
      self.scores.last.merge!(value: content)
    when "Value"
      if context.include?("Competitors")
        self.competitors.last[:name] = content
      elsif context.include?("Comment")
        self.result_comment = content
      end
    when "MatchDate"
      self.date.nil? ? self.date = "#{content.strip.lstrip}" : self.date << content
    when "P"
      self.probabilities.last.outcome_probabilities.last[:value] = content
      #TODO: Dry this up
    when "Off"
      self.off = content
    when "LiveMultiCast"
      self.live_multi_cast = content
    when "LiveScore"
      self.live_score = content
    when "Round"
      self.round = content
    when "NeutralGround"
      self.neutral_ground = content
    else
      warn "#{self.class} :: Current Element: #{current_element} - content not supported"
    end
  end

end
