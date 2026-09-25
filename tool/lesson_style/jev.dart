import 'dart:convert';
import 'dart:io';

// The rules from `.claude/skills/practice-writer/SKILL.md` that need
// understanding rather than counting, each asked as one yes/no question
// (a TypeSafe "noul") about one line of explaining text.
//
// **Every question asks whether the line BREAKS a rule**, so a high number is
// always bad and the report can sort on one direction.
//
// **The wording is literal on purpose.** TypeSafe's notes say Jev answers the
// question written, not the one meant. When a result looks wrong and you catch
// yourself explaining what the rule really means, that explanation belongs in
// the criteria below -- and probably in the skill as well.
//
// Docs: https://docs.typesafe.ai/api.md and
// https://docs.typesafe.ai/primitives/noul.md

class JevRule {
  final String id;
  final String rule;
  final String question;
  final String breaks;
  final String keeps;

  const JevRule({
    required this.id,
    required this.rule,
    required this.question,
    required this.breaks,
    required this.keeps,
  });

  Map<String, Object> toQuestion() => <String, Object>{
        'type': 'noul',
        'instructions': question,
        'criteria': <String, String>{'true': breaks, 'false': keeps},
      };
}

const List<JevRule> jevRules = <JevRule>[
  JevRule(
    id: 'soft_landing',
    rule: 'Ends on its point',
    question: 'Does `line` end on a soft landing instead of ending on its '
        'point? Look only at the last clause of each paragraph.',
    breaks: 'The last words restate or soften what was already said, wind down '
        'wistfully, add a tagline or slogan, ask a rhetorical question, or add '
        'a moral about being kind to yourself.',
    keeps: 'The last words carry the idea or the action itself, and then the '
        'text stops. Ending on "it gets easier with practice" or "it does get '
        'easier" counts as ending on the point: it is the one promise a '
        'lesson may make.',
  ),
  JevRule(
    id: 'claim_about_reader',
    rule: 'No claim about the reader',
    question: 'Does `line` state how the reader feels, what kind of person '
        'the reader is, or how well the reader is doing?',
    breaks: 'It asserts something about the reader as a fact, such as "you '
        'feel anxious", "you are a people pleaser" or "you are doing well".',
    keeps: 'It talks about a situation, a sentence, other people, what tends '
        'to happen, or what the reader could try. A conditional such as "if '
        'you feel..." or a general "when you..." is not a claim. A line that '
        'takes blame off an attempt, such as "that isn\'t you being bad at '
        'this", is not a claim either: it refuses a verdict rather than '
        'giving one.',
  ),
  JevRule(
    id: 'lecture',
    rule: 'Never shame, lecture or say what they should feel',
    question: 'Does `line` lecture the reader, shame them, or tell them what '
        'they should feel?',
    breaks: 'It moralises, scolds, implies the reader has been doing it wrong '
        'as a person, or tells them what feeling to have.',
    keeps: 'It explains what tends to help and why, and leaves the choice with '
        'the reader. Plainly teaching a skill is not a lecture.',
  ),
  JevRule(
    id: 'promise',
    rule: 'No promise or certain prediction the app cannot keep',
    question: 'Does `line` state as certain how the other person will react, '
        'how a real conversation will go, or that the reader will feel better?',
    breaks: 'It states an outcome as certain, good or bad, such as "they will '
        'listen", "they will respect you", "they\'ll dig in" or "you will feel '
        'better".',
    keeps: 'It makes no prediction, or hedges it ("they\'re likely to", "it '
        'tends to", "it can take the edge off"), or only says a skill gets '
        'easier with practice. A statement about what a sentence says or '
        'contains is not a prediction.',
  ),
  JevRule(
    id: 'undefined_term',
    rule: 'Every term defined or replaced',
    question: 'Does `line` use a psychology or technical term without saying '
        'what it means in plain words in the same text?',
    breaks: 'A reader who is not a psychologist would meet a word they may not '
        'know, such as "rumination" or "cognitive distortion", with no plain '
        'explanation beside it.',
    keeps: 'Every word is everyday language, or the term is explained in plain '
        'words right there.',
  ),
  JevRule(
    id: 'buried_nouns',
    rule: 'Verbs, not buried nouns',
    question: 'Does `line` use an abstract noun where a plain verb would say '
        'the same thing more simply?',
    breaks: 'It says things like "avoidance behaviours" instead of "when you '
        'avoid it", or "recovery occurs" instead of "people recover".',
    keeps: 'Actions are said as verbs, with somebody doing them.',
  ),
  JevRule(
    id: 'fragment',
    rule: 'No fragments as a style device',
    question: 'Does `line` contain a sentence fragment used for rhythm or '
        'effect, or a list of three things used for rhythm rather than '
        'meaning?',
    breaks: 'A piece of text stands alone as a sentence with no main verb for '
        'dramatic effect, or three items are stacked just to sound punchy.',
    keeps: 'Every sentence is complete. A list is there because it has that '
        'many things in it.',
  ),
  JevRule(
    id: 'anecdote',
    rule: 'No stories from the writer',
    question: "Does `line` tell a story about the writer's own life or "
        'experience?',
    breaks: 'The writer talks about themselves, as in "I remember when I...".',
    keeps: 'The text talks to the reader about the reader\'s situations, or '
        'gives an example that belongs to nobody in particular. Example '
        'sentences in quote marks are not the writer talking.',
  ),
];

// Above this, the line is reported as breaking the rule.
const double breaksAbove = 0.7;

// Between this and `breaksAbove`, Jev is not sure. That is the interesting
// band: it usually means the rule is worded loosely, not that the line is bad.
const double unsureAbove = 0.3;

class JevClient {
  final String apiKey;
  final String model;
  final HttpClient _http = HttpClient();

  static final Uri endpoint = Uri.parse('https://api.typesafe.ai/v1/systemone');

  JevClient(this.apiKey, {this.model = 'jev-latest'});

  // Asks every rule about one line in a single request. The questions run in
  // parallel on TypeSafe's side and cannot see one another's answers.
  Future<Map<String, double>> judge({
    required String about,
    required String where,
    required String line,
  }) async {
    final Map<String, Object> body = <String, Object>{
      'model': model,
      'state': <String, String>{
        'lesson': about,
        'where_in_the_lesson': where,
        'line': line,
      },
      'questions': <String, Object>{
        for (final JevRule r in jevRules) r.id: r.toQuestion(),
      },
    };

    final Map<String, dynamic> reply = await _post(body);
    final Map<String, dynamic> answers =
        reply['answers'] as Map<String, dynamic>;
    return <String, double>{
      for (final JevRule r in jevRules)
        r.id: ((answers[r.id] as Map<String, dynamic>)['noul'] as num)
            .toDouble(),
    };
  }

  // Retries on 429 and 529 with a growing wait, as the API reference asks.
  Future<Map<String, dynamic>> _post(Map<String, Object> body) async {
    Duration wait = const Duration(seconds: 1);
    for (int attempt = 1;; attempt++) {
      final HttpClientRequest request = await _http.postUrl(endpoint);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey')
        ..contentType = ContentType.json;
      request.write(jsonEncode(body));
      final HttpClientResponse response = await request.close();
      final String text = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(text) as Map<String, dynamic>;
      }
      final bool retryable =
          response.statusCode == 429 || response.statusCode == 529;
      if (!retryable || attempt >= 5) {
        throw HttpException(
            'TypeSafe answered ${response.statusCode}: $text', uri: endpoint);
      }
      await Future<void>.delayed(wait);
      wait *= 2;
    }
  }

  void close() => _http.close();
}
